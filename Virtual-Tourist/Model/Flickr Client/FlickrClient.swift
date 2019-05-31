//
//  FlickrClient.swift
//  Virtual-Tourist
//
//  Created by John Berndt on 5/27/19.
//  Copyright © 2019 John Berndt. All rights reserved.
//

import Foundation

class FlickrClient
{
    static let restApiKey = "3f4a09fbe71e8da37fa44bafa8d94749"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        
        case photosearch
        
        var stringValue : String {
            switch self {
            case .photosearch: return Endpoints.base
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    class func getPhotoList(completion: @escaping (Bool, Error?, FlickrSearchResponse?) -> Void) {
        
        let qItems = [URLQueryItem(name: "method", value: "flickr.photos.search"),
                      URLQueryItem(name: "api_key", value: restApiKey),
                      URLQueryItem(name: "format", value: "json"),
                      URLQueryItem(name: "nojsoncallback", value: "1"),
                      URLQueryItem(name: "lat", value: "43.204940"),
                      URLQueryItem(name: "lon", value: "-77.691951"),
                      URLQueryItem(name: "per_page", value: "21"),
                      URLQueryItem(name: "extras", value: "url_t")]
        
        //+ "?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=" + restApiKey
        // FlickrClient.getPhotoList(completion: FlickrClient.handleFlickrSearchResponse)

        taskForGETRequest(url: Endpoints.photosearch.url, queryItems: qItems, responseType: FlickrSearchResponse.self) { response, error in
            if let response = response {
                completion(true, nil, response)
            } else {
                print("false FlickrSearchResponse")
                completion(false, error, nil)
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, queryItems: [URLQueryItem], responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        var finalURL:URL = url;
        
        var components = URLComponents(url: finalURL, resolvingAgainstBaseURL: false)!
        
        components.queryItems = queryItems
        
        if let urlWithQuery = components.url {
            
            finalURL = urlWithQuery
        }
        
        print(finalURL)
        
        let request = URLRequest(url: finalURL)
        // The default HTTP method for URLRequest is “GET”.
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            print(data.description)
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    
                    
                    
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(FlickrErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
}
