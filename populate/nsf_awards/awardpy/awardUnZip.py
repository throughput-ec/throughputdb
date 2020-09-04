import tempfile
from zipfile import ZipFile
from os import listdir
import xmltodict
import sys
from awardpy.awardToDict import awardToDict
from cleantext import clean


def awardUnZip(file):
    tmpdir = tempfile.TemporaryDirectory()
    ZipFile(file).extractall(path=tmpdir.name)
    awards = []
    for i in listdir(tmpdir.name):
        with open(tmpdir.name + '/' + i, encoding="ISO-8859-1") as xml:
            try:
                awards.append(xmltodict.parse(clean(xml.read(), lower=False)))
            except Exception:
                with open('./xml_logfile.log', 'a') as logger:
                    logger.write('Failed to open ' + tmpdir.name + '/' + i
                                 + ': ' + str(sys.exc_info()[0]) + '\n')
    awardDict = []
    for i in awards:
        awardDict.append(awardToDict(i))
    return(awardDict)
