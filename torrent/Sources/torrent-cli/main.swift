//
//  main.swift
//  torrent
//
//  Created by Tyler Hall on 5/12/2025.
//

import Foundation
import torrent

let bencodedString = "16:This is a string!4:eggs"
let bencodedInt = "i14e"
//let bencodedList = "l5:green4:eggs3:and3:hame"
let bencodedList = "ll5:green4:eggs3:and3:hamel6:second4:list4:teste"
let bencodedDict = "d4:spam4:eggs5:monty4:hall4:fuck6:horsese"
let bdecoder = Bencode(data: bencodedString)
let outputString = Bencode(data: bencodedString).decode()
print(outputString)
      
let outputInt = Bencode(data: bencodedInt).decode()
print(outputInt)

let outputList = Bencode(data: bencodedList).decode()
print(outputList)
      
let outputDict = Bencode(data: bencodedDict).decode()
print(outputDict)

//var testDict: Dictionary<String, String> = [:]
//testDict[""] = ""
//print(testDict)
