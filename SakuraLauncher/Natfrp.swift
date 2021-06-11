//
//  Natfrp.swift
//  SakuraLauncher
//
//  Created by FENGberd on 6/11/21.
//

import Foundation

class Natfrp {
    static let Endpoint = "https://api.natfrp.com/launcher/"

    static var Token = ""

    static var session = URLSession(configuration: {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": "SakuraLauncherMac/" + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)]
        return config
    }())

    static func request<T: ApiResponse>(_ type: T.Type, _ action: String, _ query: String?, completion: @escaping (Result<T, Error>) -> Void) {
        var url = "\(Endpoint)\(action)?token=\(Token)"
        if let q = query {
            url += "&\(q)"
        }
        session.dataTask(with: URLRequest(url: URL(string: url)!)) { data, _, error in
            guard let json = data else {
                completion(.failure(NatfrpError.error("出现未知错误: \(error?.localizedDescription ?? "WTF")")))
                return
            }

            do {
                let r = try JSONDecoder().decode(T.self, from: json)
                if r.success {
                    completion(.success(r))
                    return
                }
                completion(.failure(NatfrpError.error(r.message ?? "API 请求失败, 未知错误")))
            } catch {
                completion(.failure(NatfrpError.error("API 返回数据异常: \(error.localizedDescription)")))
            }
        }.resume()
    }

    // REGION: API Data

    struct ApiTunnel: Codable {
        var id: Int
        var node: Int
        var name: String
        var type: String
        var note: String
        var description: String
    }

    // REGION: API Response

    struct GetUser: ApiResponse {
        var success: Bool
        var message: String?

        struct ApiUser: Codable {
            var login: Bool
            var uid: Int
            var name: String
            var meta: String
        }

        var data: ApiUser?
    }

    struct GetNodes: ApiResponse {
        var success: Bool
        var message: String?

        struct ApiNode: Codable {
            var id: Int
            var name: String
            var host: String
            var accept_new: Bool
        }

        var data: [ApiNode]?
    }

    struct GetTunnels: ApiResponse {
        var success: Bool
        var message: String?
        var data: [ApiTunnel]?
    }

    struct CreateTunnel: ApiResponse {
        var success: Bool
        var message: String?
        var data: ApiTunnel?
    }

    struct GetVersion: ApiResponse {
        var success: Bool
        var message: String?

        struct ApiVersion: Codable {
            var time: Int64
            var version: String
            var note: String
        }

        var frpc: ApiVersion?
        var launcher: ApiVersion?
    }
}

enum NatfrpError: Error {
    case error(String)
}

protocol ApiResponse: Codable {
    var success: Bool { get set }
    var message: String? { get set }
}
