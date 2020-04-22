import tempfile
from zipfile import ZipFile
from os import listdir
import xmltodict


def awardUnZip(file):
    tmpdir = tempfile.TemporaryDirectory()
    ZipFile(file).extractall(path = tmpdir.name)
    awards = []
    for i in listdir(tmpdir.name):
        with open(tmpdir.name + '/' + i) as xml:
            awards.append(xmltodict.parse(xml.read()))
    return(awards)
