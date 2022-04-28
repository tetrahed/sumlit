//
//  StripScriptTags.swift
//  SumLit
//
//  Created by Junior Etrata on 8/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Untagger

extension UntaggerManager{

    func stripScriptTags(_ source: String) -> String {

        var index = 0

        var scriptCount = 0

        var openStack : [NSRange] = []

        var currentSource = source



        while index < currentSource.count {

            let nextOpen = (currentSource as NSString).range(of: "<script", options: [], range: NSMakeRange(index, currentSource.count - index))



            var openStartIndex = index

            if let rootOpenTag = openStack.first, rootOpenTag.location != NSNotFound {

                openStartIndex = rootOpenTag.location + rootOpenTag.length

            }

            let nextClose = (currentSource as NSString).range(of: "</script>", options: [], range: NSMakeRange(openStartIndex, currentSource.count - openStartIndex))



            if nextOpen.location != NSNotFound, nextOpen.location < nextClose.location {

                index = nextOpen.location + nextOpen.length

                openStack.append(nextOpen)

                scriptCount += 1

            } else if nextClose.location != NSNotFound, nextClose.location < nextOpen.location {

                index = nextClose.location + nextClose.length



                if scriptCount > 0 {



                    let lastOpen = openStack.removeLast()

                    scriptCount -= 1

                    if scriptCount == 0 {

                        let sourceWithScriptStripped = (currentSource as NSString).replacingCharacters(in: NSMakeRange(lastOpen.location, (nextClose.location + nextClose.length) - lastOpen.location), with: "")



                        currentSource = sourceWithScriptStripped

                        index = lastOpen.location - 1

                        openStack = []

                    }

                }

            } else {

                break

            }

        }



        return currentSource

    }
}

