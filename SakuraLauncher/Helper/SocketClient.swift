//
//  SocketClient.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/14/21.
//

import Foundation

import Socket
import SwiftProtobuf

class SocketClient {
    let path: String
    let bufferSize: Int

    var connected: Bool { mainConnection.isConnected && pushConnection.isConnected }
    var onPushMessage: ((PushMessageBase) -> Void)?

    var queue = DispatchQueue(label: "Push Socket Queue", qos: .utility)
    var mainConnection, pushConnection: Socket

    init(_ path: String, bufferSize: Int = 1_048_576) {
        self.path = path
        self.bufferSize = bufferSize

        // We don't want to deal with tons of optional stuffs, so this creation is unavoidable
        mainConnection = try! Socket.create(family: .unix, type: .stream, proto: .unix)
        pushConnection = try! Socket.create(family: .unix, type: .stream, proto: .unix)
    }

    func close() {
        mainConnection.close()
        pushConnection.close()
    }

    func connect() -> Bool {
        if connected {
            return true
        }
        do {
            close()

            mainConnection = try! Socket.create(family: .unix, type: .stream, proto: .unix)
            pushConnection = try! Socket.create(family: .unix, type: .stream, proto: .unix)

            try mainConnection.connect(to: path + "service.sock")
            try pushConnection.connect(to: path + "service-push.sock")

            queue.async { [self] in
                do {
                    repeat {
                        let msg = try readMessage(pushConnection, type: PushMessageBase.self)
                        if let callback = onPushMessage {
                            DispatchQueue.main.sync {
                                callback(msg)
                            }
                        }
                    } while pushConnection.isConnected
                } catch {
                    close()
                }
            }

            return mainConnection.isConnected && pushConnection.isConnected
        } catch let e {
            // TODO: Should log this in a better way or discard it
            print(e)
            close()
        }
        return false
    }

    func request(_ message: RequestBase) -> ResponseBase {
        do {
            let data = try message.serializedData()
            var count = UInt32(data.count)

            try mainConnection.write(from: Data(bytes: &count, count: 4))
            try mainConnection.write(from: data)

            return try readMessage(mainConnection, type: ResponseBase.self)
        } catch let e {
            close()
            return ResponseBase.with {
                $0.success = false
                $0.message = "内部错误: \(e)"
            }
        }
    }

    func request(_ id: MessageID) -> ResponseBase {
        request(RequestBase.with {
            $0.type = id
        })
    }

    private func readMessage<T: SwiftProtobuf.Message>(_ connection: Socket, type _: T.Type) throws -> T {
        let size = try readBytes(connection, count: 4)
        return try T(serializedData: try readBytes(connection, count: Int(size[0]) | (Int(size[1]) << 8) | (Int(size[2]) << 16) | (Int(size[3]) << 24)))
    }

    private func readBytes(_ connection: Socket, count: Int) throws -> Data {
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: count)

        var p = buffer
        var i = count

        repeat {
            let c = try connection.read(into: p, bufSize: i, truncate: true)
            if c == 0 {
                throw SocketError.closed
            }
            p += c
            i -= c
        } while i > 0

        return Data(bytesNoCopy: buffer, count: count, deallocator: .free)
    }
}

enum SocketError: Error {
    case closed
}
