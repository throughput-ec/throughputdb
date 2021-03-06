from cleantext import clean
import json


def awardToDict(award):
    """Turn the NSF Award schema into a Python dictionary.

    Parameters
    ----------
    award : string
        Text representation of the XML file provided by the NSF.

    Returns
    -------
    dict
        A dictionary representation.

    """
    tags = award['rootTag']['Award']
    awardDict = {'AwardID': tags.get('AwardID'),
                 'AwardTitle': tags.get('AwardTitle'),
                 'AwardAmount': tags.get('AwardAmount'),
                 'ARRAAmount': tags.get('ARRAAmount'),
                 'Organization': dict(tags.get('Organization')),
                 'MinAmdLetterDate': tags.get('MinAmdLetterDate'),
                 'MaxAmdLetterDate': tags.get('MaxAmdLetterDate'),
                 'AwardInstrument': tags.get('AwardInstrument').get('Value'),
                 'AwardEffectiveDate': tags.get('AwardEffectiveDate'),
                 'AwardExpirationDate': tags.get('AwardExpirationDate'),
                 'AbstractNarration': clean(tags.get('AbstractNarration'),
                                            lower=False, no_line_breaks=True)
                 }
    if tags.get('Investigator') is None:
        awardDict['Investigator'] = [{'FirstName': None,
                                      'LastName': None,
                                      'EmailAddress': None,
                                      'StartDate': None,
                                      'EndDate': None,
                                      'RoleCode': None}]
    else:
        if type(tags.get('Investigator')) is list:
            awardDict['Investigator'] = list(map(lambda x: dict(x),
                                                 tags.get('Investigator')))
        else:
            awardDict['Investigator'] = [dict(tags.get('Investigator'))]
    if tags.get('Institution') is None:
        awardDict['Institution'] = [{'Name': None,
                                     'CityName': None,
                                     'ZipCode': None,
                                     'PhoneNumber': None,
                                     'StreetAddress': None,
                                     'CountryName': None,
                                     'StateName': None,
                                     'StateCode': None}]
    else:
        if type(tags.get('Institution')) is list:
            awardDict['Institution'] = list(map(lambda x: dict(x),
                                            tags.get('Institution')))
        else:
            awardDict['Institution'] = [dict(tags.get('Institution'))]
    if tags.get('ProgramElement') is None:
        awardDict['ProgramElement'] = {'Code': None,
                                       'Text': None}
    else:
        if type(tags.get('ProgramElement')) is list:
            awardDict['ProgramElement'] = list(
                map(lambda x: dict(x), tags.get('ProgramElement')))
        else:
            awardDict['ProgramElement'] = [dict(tags.get('ProgramElement'))]
    if tags.get('ProgramReference') is None:
        awardDict['ProgramReference'] = {'Code': None,
                                         'Text': None}
    else:
        if type(tags.get('ProgramReference')) is list:
            awardDict['ProgramReference'] = list(
                map(lambda x: dict(x), tags.get('ProgramReference')))
        else:
            awardDict['ProgramReference'] = [dict(tags.get('ProgramReference'))]
    awardDict = json.loads(json.dumps(awardDict))
    return awardDict
