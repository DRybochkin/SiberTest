//
//  main.swift
//  SiberTest
//
//  Created by Dmitry Rybochkin on 07.04.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Foundation

let data: [((Int, Int), (Int, Int))] = [((0,0),(40,40)),((100,0),(125,25)),((0,100),(30,130)),((100,100),(200,150)),((250,140),(350,200)),((150,250),(300,300)),((225,125),(240,140)),((345,285),(350,300))]

var xCoords: [Int] = [0]
var yCoords: [Int] = [0]

func isEmpty(coord0: (Int, Int), coord1: (Int, Int)) -> Bool {
    for i in 0..<data.count {
        if (coord0.0 >= data[i].0.0) && (coord1.0 <= data[i].1.0) && (coord0.1 >= data[i].0.1) && (coord1.1 <= data[i].1.1) {
            return false
        }
    }
    return true
}

func getColor(coord0: (Int, Int), coord1: (Int, Int)) -> String {
    return isEmpty(coord0: coord0, coord1: coord1) ? "grey" : "red"
}

func prepareData() {
    for i in 0..<data.count {
        if !xCoords.contains(data[i].0.0) {
            xCoords.append(data[i].0.0)
        }
        if !xCoords.contains(data[i].1.0) {
            xCoords.append(data[i].1.0)
        }
        if !yCoords.contains(data[i].0.1) {
            yCoords.append(data[i].0.1)
        }
        if !yCoords.contains(data[i].1.1) {
            yCoords.append(data[i].1.1)
        }
    }
    
    xCoords.sort()
    yCoords.sort()
}

func simple(_ showBorder: Bool = true) -> String {
    prepareData()
    
    let border = showBorder ? "border=\"1\"" : ""
    
    var res = "<html>\n<body>\n<table \(border) cellspacing=\"0\" cellpadding=\"0\">\n"
    
    for i in 1..<xCoords.count {
        res += "<col width=\"\(xCoords[i]-xCoords[i-1])\">\n"
    }
    
    for y in 1..<yCoords.count {
        res += "<tr height=\"\(yCoords[y]-yCoords[y-1])\">\n"
        for x in 1..<xCoords.count {
            res += "<td bgcolor=\"\(getColor(coord0: (xCoords[x-1], yCoords[y-1]), coord1: (xCoords[x], yCoords[y])))\"></td>\n"
        }
        res += "</tr>\n"
    }
    
    res += "</table>\n</body>\n</html>"
    return res
}

/*
 Нечто похожее на метод заметания отрезком (эффективней заметать спиралью, но не сегодня)
 */
func span(_ showBorder: Bool = true) -> String {
    prepareData()

    let border = showBorder ? "border=\"1\"" : ""
    
    var res = "<table \(border) cellspacing=\"0\" cellpadding=\"0\">\n"
    
    for i in 1..<xCoords.count {
        res += "<col width=\"\(xCoords[i]-xCoords[i-1])\">\n"
    }
    
    var col = 0
    var raw = 0
    
    while raw < yCoords.count-1 {
        res += "<tr height=\"\(yCoords[raw+1]-yCoords[raw])\">\n"
        col = 0
        while col<xCoords.count-1 {
            var startCol = col
            while (col<xCoords.count-1) && (isEmpty(coord0: (xCoords[col], yCoords[raw]), coord1: (xCoords[col+1], yCoords[raw+1]))) {
                col += 1
            }
            if col > 0 {
                res += "<td colspan=\"\(col-startCol)\" bgcolor=\"gray\">"
            }
            if (col<xCoords.count-1) {
                var localRaw = raw
                while (localRaw<yCoords.count-1) && (!isEmpty(coord0: (xCoords[col], yCoords[localRaw]), coord1: (xCoords[col+1], yCoords[localRaw+1]))) {
                    localRaw += 1
                }
                startCol = col
                while (col<xCoords.count-1) && (!isEmpty(coord0: (xCoords[col], yCoords[raw]), coord1: (xCoords[col+1], yCoords[raw+1]))) {
                    col += 1
                }
                if (raw == 0) || (isEmpty(coord0: (xCoords[startCol], yCoords[raw-1]), coord1: (xCoords[startCol+1], yCoords[raw]))) {
                    res += "<td colspan=\"\(col-startCol)\" rowspan=\"\(localRaw-raw)\" bgcolor=\"red\">"
                }
            } else {
                col += 1
            }
        }
        raw += 1
    }
    
    res += "</table>"
    return res
}

let file = "sibertest.html"
if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    let path = dir.appendingPathComponent(file)
    do {
        let html = "<html>\n" +
                        "<body>\n" +
                            "<table>\n" +
                                "<thead>\n" +
                                    "<th>with border</th>\n" +
                                    "<th>without border</th>\n" +
                                "</thead>\n" +
                                "<tbody>\n" +
                                    "<tr>\n" +
                                        "<td>\(simple())</td>\n" +
                                        "<td>\(simple(false))</td>\n" +
                                    "</tr>\n" +
                                    "<tr>\n" +
                                        "<td>\(span())\n</td>\n" +
                                        "<td>\(span(false))</td>\n" +
                                    "</tr>\n" +
                                "</tbody>\n" +
                            "</table>\n" +
                        "</body>\n" +
                    "</html>"
        try html.write(to: path, atomically: false, encoding: String.Encoding.utf8)
    }
    catch {}
}


print("Done")
