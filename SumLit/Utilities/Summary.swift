//
//  Summary.swift
//  Different Summary
//
//  Created by Robert Chung on 7/19/19.
//  Copyright © 2019 WannaInternet. All rights reserved.
//

import Foundation

public class Summary
{
    private struct Sentence
    {
        var textRange: NSRange = NSRange(location: 0, length: 0)
        var words: [String] = []
        var index: Int = 0
        var ranking: Int = 0
    }
    
    let options: NSLinguisticTagger.Options
    let tagger: NSLinguisticTagger
    
    let stopWords = ["a", "about", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also", "although", "always", "am", "among", "amongst", "amoungst", "amount", "an", "and", "another", "any", " anyhow", "anyone", "anything", "anyway", "anywhere", "are", "around", "as", "at", "back", "be", "became", "because", "become", "becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom", "but", "by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each", "eg", "eight", "either", "eleven", "else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own", "part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves"]
    
    init()
    {
        options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en")
        tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
    }
    
    public func getSummary(text: String, numberOfSentences: Int) -> String
    {
        guard numberOfSentences > 0 else
        {
            return ""
        }
        
        var sentences: [Sentence] = []
        var sentence = Sentence()
        
        var wordFrequencies: [String: Int] = [:]
        
        tagger.string = text
        
        tagger.enumerateTags(in: text.nsrange, scheme: .nameType, options: options)
        { (tag, tokenRange, sentenceRange, _)
            in
            
            //If we've switched to a new sentence then append the previous to the array
            if sentence.textRange != sentenceRange
            {
                if sentence.textRange.length > 0
                {
                    sentence.index = sentences.count
                    sentences.append(sentence)
                }
                sentence = Sentence()
                sentence.textRange = sentenceRange
            }
            
            //Convert to lowercase and if not a stopword the increase the word frequency.
            if let word = text[tokenRange]?.lowercased()
            {
                if !stopWords.contains(word)
                {
                    wordFrequencies[word, default: 0] += 1
                    sentence.words.append(word)
                }
            }
        }
        
        //Calculate Sentence Rankings
        for i in sentences.indices
        {
            sentences[i].ranking = sentences[i].words.reduce(0,
            { (rank, word) -> Int in
                rank + wordFrequencies[word, default: 0]
            })
        }
        
        let sentencesByRanking = sentences.sorted
        { $0.ranking > $1.ranking }
        
        //Select the most important sentences
        let keySentences = sentencesByRanking.prefix(numberOfSentences).sorted
        { $0.index < $1.index }
        
        //Build summary based on the most important sentences
        var summary = ""
        var firstSentence = true
        for sentence in keySentences {
            guard let text = text[sentence.textRange]
            else {
                continue
            }
            
            if firstSentence {
                firstSentence = false
            }
            else {
                summary.append(" ")
            }
            
            summary.append(text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return summary
    }
}

extension String
{
    var nsrange: NSRange {
        return NSRange(location: 0, length: self.utf16.count)
    }
    
    subscript(nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self)
        else {
            return nil
        }
        return self[range]
    }
}

