#!/usr/bin/python

import ranking
import unittest

class Test(unittest.TestCase):

    def test_read_pair2images_csv(self):
        ra = ranking.Ranking()
        ra.read_pair2images_csv("sunspotzooniverse_pair2images.csv")
        self.assertEqual(ra.images2pair[0,10],9)
        self.assertEqual(ra.pair2images[14],(1,2))

    def test_read_classification_csv(self):
        ra = ranking.Ranking()
        ra.read_classification_csv("201304_FMI.txt")
        self.assertEqual(ra.larger[75][0],'A','Issue with larger')
        self.assertEqual(ra.stronger[77][0],'B', 'Issue wth stronger')
        self.assertEqual(ra.compacter[9][0],'B', 'Issue with compacter')
        self.assertEqual(ra.complexer[7][0],'A', 'Issue with compelxer')

    def test_get_ranking(self):
        ra = ranking.Ranking()
        ra.read_pair2images_csv("sunspotzooniverse_pair2images.csv")
        ra.read_classification_csv("201304_FMI.txt")
        lr = ra.get_ranking(ra.larger)
        self.assertEqual(len(lr),15)


if __name__ == "__main__":
    unittest.main()
