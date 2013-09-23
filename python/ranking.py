#!/usr/bin/python

import csv
import math

class Ranking(object):
    def __init__(self):
        self.pair2images = {}
        self.images2pair = {}
        self.images = set()
        self.larger = {}
        self.stronger ={}
        self.compacter = {}
        self.complexer = {}

    def insert(self, d, key, value):
        if not key in d:
            d[key]= []
        d[key].append(value)

    def read_pair2images_csv(self, csvfn):
        """
        Read mapping from pair number to image numbers.

        Data format is CSV with columns: Pair Number, Image A, Image B
        """

        with open(csvfn, 'rU') as csvfile:
            csvr = csv.reader(csvfile)
            for row in csvr:
                if row[0].startswith('#'):
                    continue
                (p, a, b) = [int(c) for c in row[0:3]]
                self.images.add(a)
                self.images.add(b)
                self.pair2images[p] = (a,b)
                self.images2pair[(a,b)] = p
    


    def read_classification_csv(self, csvfn):
        """
        Read classification results.

        Data form is CSV with columns: 

        Classifier ID, Pair Number, Larger, Stronger, Compact, Complex
        """
        with open(csvfn, 'rU') as csvfile:
            csvr = csv.reader(csvfile)
            for row in csvr:
                if row[0].startswith('#'):
                    continue
                #ignore classifier ID
                (_, p, larger, stronger, compacter, complexer) = row[0:6]
                p = int(p)

                self.insert(self.larger, p, larger)
                self.insert(self.stronger, p, stronger)
                self.insert(self.compacter, p, compacter)
                self.insert(self.complexer, p, complexer)


    def get_ranking(self, d):
        """
        d is the ranking information to use (e.g. self.larger)

        Return
            list of image numbers sorted by given ranking information
        """
        def cmp_images(a, b):
            if (a < b):
                sense = 1
                ims = (a,b)
            else:
                sense = -1
                ims = (b,a)
                
            p = self.images2pair[ims]
            return math.copysign(votes_to_cmp(d[p]), sense)

        from functools import cmp_to_key
        l = list(self.images) #unranked list of images

        return sorted(l, key=cmp_to_key(cmp_images))

def votes_to_cmp(l):
    """

    Arguments
        l: list of votes e.g. ['A','B','B','-']

    Return
        Negative number if mostly 'A'
        Positive number if mostly 'B'
        Zero if mostly '-'
        
    """
    count = len(l)
    total = 0.0
    for item in l:
        if item == 'A':
            total -= 1
        elif item == 'B':
            total += 1
        elif item == '-':
            pass
        else:
            pass


    mean = total / count
    abs_ceil = math.ceil(abs(mean))
    #print "mean: %f, abs(mean) %f, ceil(abs(mean)) %f" %(mean, abs(mean), abs_ceil)

    return int(math.copysign(abs_ceil, mean))

