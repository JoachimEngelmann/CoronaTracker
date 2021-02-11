//
//  rki_API.swift
//  Corona Index
//
//  Created by Joachim Engelmann on 28.10.20.
//  Copyright © 2020 Joachim Engelmann. All rights reserved.
//

import Foundation

class Rki_Api{
    static func getIncidenceData(latitude: Double, longtitude: Double, completion: @escaping (_ data: AttributesDistrictInformation) -> Void){
        let apiUrl = URL(string:  "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=1%3D1&outFields=GEN,cases7_per_100k,RS&geometry=" + (String(format: "%.3f", longtitude)) + "%2C" + (String(format: "%.3f", latitude)) + "&geometryType=esriGeometryPoint&inSR=4326&spatialRel=esriSpatialRelWithin&returnGeometry=false&outSR=4326&f=json")!
        
        // Send HTTP Request
        URLSession.shared.dataTask(with: apiUrl) { (data, response, error) in
            if let dataResponse = data{
                let dataResponse: RKIData = try! JSONDecoder().decode(RKIData<AttributesDistrictInformation>.self, from: dataResponse)
                completion(dataResponse.features[0].attributes)
            }
        }.resume()
    }
    
    static func getIncidenceData(districtName: String, completion: @escaping (_ data: AttributesDistrictInformation) -> Void){
        let district_tmp = districtName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        guard let apiUrl = URL(string:  "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_Landkreisdaten/FeatureServer/0/query?where=GEN%20%3D%20%27" + district_tmp! + "%27&outFields=GEN,cases7_per_100k,RS&returnGeometry=false&outSR=4326&f=json") else {return}
        
        // Send HTTP Request
        URLSession.shared.dataTask(with: apiUrl) { (data, response, error) in
            if let dataResponse = data{
                let dataResponse: RKIData = try! JSONDecoder().decode(RKIData<AttributesDistrictInformation>.self, from: dataResponse)
                if(dataResponse.features.count != 0){
                    completion(dataResponse.features[0].attributes)
                }
            }
        }.resume()
    }
    
    static func getTrendData(districtID: String, previousDays: Double, completion: @escaping (_ data: [AttributesInfectedPerDay]) -> Void){
        let iso8601DateFormatter = ISO8601DateFormatter()
        iso8601DateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let dateNow = String(iso8601DateFormatter.string(from: Date()).prefix(10))
        let dateLatest = String(iso8601DateFormatter.string(from: Date().addingTimeInterval(previousDays*24*60*60)).prefix(10))

        guard let apiURL = URL(string:  "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query?where=IdLandkreis%20%3D%20%27" + districtID + "%27%20AND%20Meldedatum%20%3E%3D%20TIMESTAMP%20%27" + dateLatest + "%2000%3A00%3A00%27%20AND%20Meldedatum%20%3C%3D%20TIMESTAMP%20%27" + dateNow + "%2000%3A00%3A00%27&outFields=Meldedatum,AnzahlFall&outSR=4326&f=json") else {return}
        
        // Send HTTP Request
        URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            if let dataResponse = data{
                let dataResponse: RKIData = try! JSONDecoder().decode(RKIData<AttributesInfectedPerDay>.self, from: dataResponse)
                if(dataResponse.features.count != 0){
                    var returnVal: [AttributesInfectedPerDay] = [AttributesInfectedPerDay]()
                    
                    dataResponse.features.forEach(){entry in
                        returnVal.append(entry.attributes)
                    }
                    
                    completion(returnVal)
                }
            }
        }.resume()
    }
}

private struct RKIData<Type: Codable>: Codable {
    struct Feature<Type: Codable>: Codable {
        let attributes: Type
    }
    
    let features: [Feature<Type>]
}

struct AttributesDistrictInformation: Codable {
    let name: String
    let cases7Per100K: Double
    let districtID: String

    enum CodingKeys: String, CodingKey {
        case name = "GEN"
        case cases7Per100K = "cases7_per_100k"
        case districtID = "RS"
    }
}
struct AttributesInfectedPerDay: Codable {
    let reportingDate: Int
    let cases: Int

    enum CodingKeys: String, CodingKey {
        case reportingDate = "Meldedatum"
        case cases = "AnzahlFall"
    }
}
