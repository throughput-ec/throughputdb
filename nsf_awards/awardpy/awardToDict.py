from cleantext import clean


def awardToDict(award):
    tags = award['rootTag']['Award']
    awardDict = {'AwardID': tags.get('AwardID'),
                 'AwardTitle': tags.get('AwardTitle'),
                 'AwardAmount': tags.get('AwardAmount'),
                 'ARRAAmount': tags.get('ARRAAmount'),
                 'OrganizationCode': tags.get('Organization').get('Code'),
                 'OrganizationDirectorate': tags.get('Organization').get('Directorate').get('LongName'),
                 'OrganizationDivision': tags.get('Organization').get('Division').get('LongName'),
                 'MinAmdLetterDate': tags.get('MinAmdLetterDate'),
                 'MaxAmdLetterDate': tags.get('MaxAmdLetterDate'),
                 'AwardInstrument': tags.get('AwardInstrument').get('Value'),
                 'AwardEffectiveDate': tags.get('AwardEffectiveDate'),
                 'AwardExpirationDate': tags.get('AwardExpirationDate'),
                 'AbstractNarration': clean(tags.get('AbstractNarration'),
                                            lower=False, no_line_breaks=True)
                }

    if tags.get('Institution') is None:
        awardDict['InstitutionStateName'] = None
        awardDict['InstitutionStateCode'] = None
        awardDict['InstitutionCountryName'] = None
        awardDict['InstitutionName'] = None
        awardDict['InstitutionPhoneNumber'] = None
        awardDict['InstitutionCityName'] = None
        awardDict['InstitutionStreetAddress'] = None
        awardDict['InstitutionZipCode'] = None
    else:
        awardDict['InstitutionStateName'] = tags.get('Institution').get('StateName')
        awardDict['InstitutionStateCode'] = tags.get('Institution').get('StateCode')
        awardDict['InstitutionCountryName'] = tags.get('Institution').get('CountryName')
        awardDict['InstitutionName'] = tags.get('Institution').get('Name')
        awardDict['InstitutionPhoneNumber'] = tags.get('Institution').get('PhoneNumber')
        awardDict['InstitutionCityName'] = tags.get('Institution').get('CityName')
        awardDict['InstitutionStreetAddress'] = tags.get('Institution').get('StreetAddress')
        awardDict['InstitutionZipCode'] = tags.get('Institution').get('ZipCode')

    if type(tags.get('ProgramElement')) is list:
        awardDict['ProgramElementCode'] = list(map(lambda x: x.get('Code'), tags.get('ProgramElement')))
        awardDict['ProgramElementText'] = list(map(lambda x: x.get('Text'), tags.get('ProgramElement')))
    else:
        if type(tags.get('ProgramElement')) is None:
            awardDict['ProgramElementCode'] = None
            awardDict['ProgramElementText'] = None
        else:
            awardDict['ProgramElementCode'] = tags.get('ProgramElement').get('Code')
            awardDict['ProgramElementText'] = tags.get('ProgramElement').get('Text')
    if type(tags.get('ProgramReference')) is list:
        awardDict['ProgramReferenceCode'] = list(map(lambda x: x.get('Code'), tags.get('ProgramReference')))
        awardDict['ProgramReferenceText'] = list(map(lambda x: x.get('Text'), tags.get('ProgramReference')))
    else:
        if type(tags.get('ProgramElement')) is None:
            awardDict['ProgramReferenceCode'] = None
            awardDict['ProgramReferenceText'] = None
        else:
            awardDict['ProgramReferenceCode'] = tags.get('ProgramReference').get('Code')
            awardDict['ProgramReferenceText'] = tags.get('ProgramReference').get('Text')
    return awardDict
