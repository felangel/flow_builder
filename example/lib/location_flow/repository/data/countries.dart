import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

final _countries = '''[
	{
		"id": "1",
		"sortname": "AF",
		"name": "Afghanistan",
		"phonecode": "93"
	},
	{
		"id": "2",
		"sortname": "AL",
		"name": "Albania",
		"phonecode": "355"
	},
	{
		"id": "3",
		"sortname": "DZ",
		"name": "Algeria",
		"phonecode": "213"
	},
	{
		"id": "4",
		"sortname": "AS",
		"name": "American Samoa",
		"phonecode": "1684"
	},
	{
		"id": "5",
		"sortname": "AD",
		"name": "Andorra",
		"phonecode": "376"
	},
	{
		"id": "6",
		"sortname": "AO",
		"name": "Angola",
		"phonecode": "244"
	},
	{
		"id": "7",
		"sortname": "AI",
		"name": "Anguilla",
		"phonecode": "1264"
	},
	{
		"id": "8",
		"sortname": "AQ",
		"name": "Antarctica",
		"phonecode": "0"
	},
	{
		"id": "9",
		"sortname": "AG",
		"name": "Antigua And Barbuda",
		"phonecode": "1268"
	},
	{
		"id": "10",
		"sortname": "AR",
		"name": "Argentina",
		"phonecode": "54"
	},
	{
		"id": "11",
		"sortname": "AM",
		"name": "Armenia",
		"phonecode": "374"
	},
	{
		"id": "12",
		"sortname": "AW",
		"name": "Aruba",
		"phonecode": "297"
	},
	{
		"id": "13",
		"sortname": "AU",
		"name": "Australia",
		"phonecode": "61"
	},
	{
		"id": "14",
		"sortname": "AT",
		"name": "Austria",
		"phonecode": "43"
	},
	{
		"id": "15",
		"sortname": "AZ",
		"name": "Azerbaijan",
		"phonecode": "994"
	},
	{
		"id": "16",
		"sortname": "BS",
		"name": "Bahamas The",
		"phonecode": "1242"
	},
	{
		"id": "17",
		"sortname": "BH",
		"name": "Bahrain",
		"phonecode": "973"
	},
	{
		"id": "18",
		"sortname": "BD",
		"name": "Bangladesh",
		"phonecode": "880"
	},
	{
		"id": "19",
		"sortname": "BB",
		"name": "Barbados",
		"phonecode": "1246"
	},
	{
		"id": "20",
		"sortname": "BY",
		"name": "Belarus",
		"phonecode": "375"
	},
	{
		"id": "21",
		"sortname": "BE",
		"name": "Belgium",
		"phonecode": "32"
	},
	{
		"id": "22",
		"sortname": "BZ",
		"name": "Belize",
		"phonecode": "501"
	},
	{
		"id": "23",
		"sortname": "BJ",
		"name": "Benin",
		"phonecode": "229"
	},
	{
		"id": "24",
		"sortname": "BM",
		"name": "Bermuda",
		"phonecode": "1441"
	},
	{
		"id": "25",
		"sortname": "BT",
		"name": "Bhutan",
		"phonecode": "975"
	},
	{
		"id": "26",
		"sortname": "BO",
		"name": "Bolivia",
		"phonecode": "591"
	},
	{
		"id": "27",
		"sortname": "BA",
		"name": "Bosnia and Herzegovina",
		"phonecode": "387"
	},
	{
		"id": "28",
		"sortname": "BW",
		"name": "Botswana",
		"phonecode": "267"
	},
	{
		"id": "29",
		"sortname": "BV",
		"name": "Bouvet Island",
		"phonecode": "0"
	},
	{
		"id": "30",
		"sortname": "BR",
		"name": "Brazil",
		"phonecode": "55"
	},
	{
		"id": "31",
		"sortname": "IO",
		"name": "British Indian Ocean Territory",
		"phonecode": "246"
	},
	{
		"id": "32",
		"sortname": "BN",
		"name": "Brunei",
		"phonecode": "673"
	},
	{
		"id": "33",
		"sortname": "BG",
		"name": "Bulgaria",
		"phonecode": "359"
	},
	{
		"id": "34",
		"sortname": "BF",
		"name": "Burkina Faso",
		"phonecode": "226"
	},
	{
		"id": "35",
		"sortname": "BI",
		"name": "Burundi",
		"phonecode": "257"
	},
	{
		"id": "36",
		"sortname": "KH",
		"name": "Cambodia",
		"phonecode": "855"
	},
	{
		"id": "37",
		"sortname": "CM",
		"name": "Cameroon",
		"phonecode": "237"
	},
	{
		"id": "38",
		"sortname": "CA",
		"name": "Canada",
		"phonecode": "1"
	},
	{
		"id": "39",
		"sortname": "CV",
		"name": "Cape Verde",
		"phonecode": "238"
	},
	{
		"id": "40",
		"sortname": "KY",
		"name": "Cayman Islands",
		"phonecode": "1345"
	},
	{
		"id": "41",
		"sortname": "CF",
		"name": "Central African Republic",
		"phonecode": "236"
	},
	{
		"id": "42",
		"sortname": "TD",
		"name": "Chad",
		"phonecode": "235"
	},
	{
		"id": "43",
		"sortname": "CL",
		"name": "Chile",
		"phonecode": "56"
	},
	{
		"id": "44",
		"sortname": "CN",
		"name": "China",
		"phonecode": "86"
	},
	{
		"id": "45",
		"sortname": "CX",
		"name": "Christmas Island",
		"phonecode": "61"
	},
	{
		"id": "46",
		"sortname": "CC",
		"name": "Cocos (Keeling) Islands",
		"phonecode": "672"
	},
	{
		"id": "47",
		"sortname": "CO",
		"name": "Colombia",
		"phonecode": "57"
	},
	{
		"id": "48",
		"sortname": "KM",
		"name": "Comoros",
		"phonecode": "269"
	},
	{
		"id": "49",
		"sortname": "CG",
		"name": "Congo",
		"phonecode": "242"
	},
	{
		"id": "50",
		"sortname": "CD",
		"name": "Congo The Democratic Republic Of The",
		"phonecode": "242"
	},
	{
		"id": "51",
		"sortname": "CK",
		"name": "Cook Islands",
		"phonecode": "682"
	},
	{
		"id": "52",
		"sortname": "CR",
		"name": "Costa Rica",
		"phonecode": "506"
	},
	{
		"id": "53",
		"sortname": "CI",
		"name": "Cote D''Ivoire (Ivory Coast)",
		"phonecode": "225"
	},
	{
		"id": "54",
		"sortname": "HR",
		"name": "Croatia (Hrvatska)",
		"phonecode": "385"
	},
	{
		"id": "55",
		"sortname": "CU",
		"name": "Cuba",
		"phonecode": "53"
	},
	{
		"id": "56",
		"sortname": "CY",
		"name": "Cyprus",
		"phonecode": "357"
	},
	{
		"id": "57",
		"sortname": "CZ",
		"name": "Czech Republic",
		"phonecode": "420"
	},
	{
		"id": "58",
		"sortname": "DK",
		"name": "Denmark",
		"phonecode": "45"
	},
	{
		"id": "59",
		"sortname": "DJ",
		"name": "Djibouti",
		"phonecode": "253"
	},
	{
		"id": "60",
		"sortname": "DM",
		"name": "Dominica",
		"phonecode": "1767"
	},
	{
		"id": "61",
		"sortname": "DO",
		"name": "Dominican Republic",
		"phonecode": "1809"
	},
	{
		"id": "62",
		"sortname": "TP",
		"name": "East Timor",
		"phonecode": "670"
	},
	{
		"id": "63",
		"sortname": "EC",
		"name": "Ecuador",
		"phonecode": "593"
	},
	{
		"id": "64",
		"sortname": "EG",
		"name": "Egypt",
		"phonecode": "20"
	},
	{
		"id": "65",
		"sortname": "SV",
		"name": "El Salvador",
		"phonecode": "503"
	},
	{
		"id": "66",
		"sortname": "GQ",
		"name": "Equatorial Guinea",
		"phonecode": "240"
	},
	{
		"id": "67",
		"sortname": "ER",
		"name": "Eritrea",
		"phonecode": "291"
	},
	{
		"id": "68",
		"sortname": "EE",
		"name": "Estonia",
		"phonecode": "372"
	},
	{
		"id": "69",
		"sortname": "ET",
		"name": "Ethiopia",
		"phonecode": "251"
	},
	{
		"id": "70",
		"sortname": "XA",
		"name": "External Territories of Australia",
		"phonecode": "61"
	},
	{
		"id": "71",
		"sortname": "FK",
		"name": "Falkland Islands",
		"phonecode": "500"
	},
	{
		"id": "72",
		"sortname": "FO",
		"name": "Faroe Islands",
		"phonecode": "298"
	},
	{
		"id": "73",
		"sortname": "FJ",
		"name": "Fiji Islands",
		"phonecode": "679"
	},
	{
		"id": "74",
		"sortname": "FI",
		"name": "Finland",
		"phonecode": "358"
	},
	{
		"id": "75",
		"sortname": "FR",
		"name": "France",
		"phonecode": "33"
	},
	{
		"id": "76",
		"sortname": "GF",
		"name": "French Guiana",
		"phonecode": "594"
	},
	{
		"id": "77",
		"sortname": "PF",
		"name": "French Polynesia",
		"phonecode": "689"
	},
	{
		"id": "78",
		"sortname": "TF",
		"name": "French Southern Territories",
		"phonecode": "0"
	},
	{
		"id": "79",
		"sortname": "GA",
		"name": "Gabon",
		"phonecode": "241"
	},
	{
		"id": "80",
		"sortname": "GM",
		"name": "Gambia The",
		"phonecode": "220"
	},
	{
		"id": "81",
		"sortname": "GE",
		"name": "Georgia",
		"phonecode": "995"
	},
	{
		"id": "82",
		"sortname": "DE",
		"name": "Germany",
		"phonecode": "49"
	},
	{
		"id": "83",
		"sortname": "GH",
		"name": "Ghana",
		"phonecode": "233"
	},
	{
		"id": "84",
		"sortname": "GI",
		"name": "Gibraltar",
		"phonecode": "350"
	},
	{
		"id": "85",
		"sortname": "GR",
		"name": "Greece",
		"phonecode": "30"
	},
	{
		"id": "86",
		"sortname": "GL",
		"name": "Greenland",
		"phonecode": "299"
	},
	{
		"id": "87",
		"sortname": "GD",
		"name": "Grenada",
		"phonecode": "1473"
	},
	{
		"id": "88",
		"sortname": "GP",
		"name": "Guadeloupe",
		"phonecode": "590"
	},
	{
		"id": "89",
		"sortname": "GU",
		"name": "Guam",
		"phonecode": "1671"
	},
	{
		"id": "90",
		"sortname": "GT",
		"name": "Guatemala",
		"phonecode": "502"
	},
	{
		"id": "91",
		"sortname": "XU",
		"name": "Guernsey and Alderney",
		"phonecode": "44"
	},
	{
		"id": "92",
		"sortname": "GN",
		"name": "Guinea",
		"phonecode": "224"
	},
	{
		"id": "93",
		"sortname": "GW",
		"name": "Guinea-Bissau",
		"phonecode": "245"
	},
	{
		"id": "94",
		"sortname": "GY",
		"name": "Guyana",
		"phonecode": "592"
	},
	{
		"id": "95",
		"sortname": "HT",
		"name": "Haiti",
		"phonecode": "509"
	},
	{
		"id": "96",
		"sortname": "HM",
		"name": "Heard and McDonald Islands",
		"phonecode": "0"
	},
	{
		"id": "97",
		"sortname": "HN",
		"name": "Honduras",
		"phonecode": "504"
	},
	{
		"id": "98",
		"sortname": "HK",
		"name": "Hong Kong S.A.R.",
		"phonecode": "852"
	},
	{
		"id": "99",
		"sortname": "HU",
		"name": "Hungary",
		"phonecode": "36"
	},
	{
		"id": "100",
		"sortname": "IS",
		"name": "Iceland",
		"phonecode": "354"
	},
	{
		"id": "101",
		"sortname": "IN",
		"name": "India",
		"phonecode": "91"
	},
	{
		"id": "102",
		"sortname": "ID",
		"name": "Indonesia",
		"phonecode": "62"
	},
	{
		"id": "103",
		"sortname": "IR",
		"name": "Iran",
		"phonecode": "98"
	},
	{
		"id": "104",
		"sortname": "IQ",
		"name": "Iraq",
		"phonecode": "964"
	},
	{
		"id": "105",
		"sortname": "IE",
		"name": "Ireland",
		"phonecode": "353"
	},
	{
		"id": "106",
		"sortname": "IL",
		"name": "Israel",
		"phonecode": "972"
	},
	{
		"id": "107",
		"sortname": "IT",
		"name": "Italy",
		"phonecode": "39"
	},
	{
		"id": "108",
		"sortname": "JM",
		"name": "Jamaica",
		"phonecode": "1876"
	},
	{
		"id": "109",
		"sortname": "JP",
		"name": "Japan",
		"phonecode": "81"
	},
	{
		"id": "110",
		"sortname": "XJ",
		"name": "Jersey",
		"phonecode": "44"
	},
	{
		"id": "111",
		"sortname": "JO",
		"name": "Jordan",
		"phonecode": "962"
	},
	{
		"id": "112",
		"sortname": "KZ",
		"name": "Kazakhstan",
		"phonecode": "7"
	},
	{
		"id": "113",
		"sortname": "KE",
		"name": "Kenya",
		"phonecode": "254"
	},
	{
		"id": "114",
		"sortname": "KI",
		"name": "Kiribati",
		"phonecode": "686"
	},
	{
		"id": "115",
		"sortname": "KP",
		"name": "Korea North",
		"phonecode": "850"
	},
	{
		"id": "116",
		"sortname": "KR",
		"name": "Korea South",
		"phonecode": "82"
	},
	{
		"id": "117",
		"sortname": "KW",
		"name": "Kuwait",
		"phonecode": "965"
	},
	{
		"id": "118",
		"sortname": "KG",
		"name": "Kyrgyzstan",
		"phonecode": "996"
	},
	{
		"id": "119",
		"sortname": "LA",
		"name": "Laos",
		"phonecode": "856"
	},
	{
		"id": "120",
		"sortname": "LV",
		"name": "Latvia",
		"phonecode": "371"
	},
	{
		"id": "121",
		"sortname": "LB",
		"name": "Lebanon",
		"phonecode": "961"
	},
	{
		"id": "122",
		"sortname": "LS",
		"name": "Lesotho",
		"phonecode": "266"
	},
	{
		"id": "123",
		"sortname": "LR",
		"name": "Liberia",
		"phonecode": "231"
	},
	{
		"id": "124",
		"sortname": "LY",
		"name": "Libya",
		"phonecode": "218"
	},
	{
		"id": "125",
		"sortname": "LI",
		"name": "Liechtenstein",
		"phonecode": "423"
	},
	{
		"id": "126",
		"sortname": "LT",
		"name": "Lithuania",
		"phonecode": "370"
	},
	{
		"id": "127",
		"sortname": "LU",
		"name": "Luxembourg",
		"phonecode": "352"
	},
	{
		"id": "128",
		"sortname": "MO",
		"name": "Macau S.A.R.",
		"phonecode": "853"
	},
	{
		"id": "129",
		"sortname": "MK",
		"name": "Macedonia",
		"phonecode": "389"
	},
	{
		"id": "130",
		"sortname": "MG",
		"name": "Madagascar",
		"phonecode": "261"
	},
	{
		"id": "131",
		"sortname": "MW",
		"name": "Malawi",
		"phonecode": "265"
	},
	{
		"id": "132",
		"sortname": "MY",
		"name": "Malaysia",
		"phonecode": "60"
	},
	{
		"id": "133",
		"sortname": "MV",
		"name": "Maldives",
		"phonecode": "960"
	},
	{
		"id": "134",
		"sortname": "ML",
		"name": "Mali",
		"phonecode": "223"
	},
	{
		"id": "135",
		"sortname": "MT",
		"name": "Malta",
		"phonecode": "356"
	},
	{
		"id": "136",
		"sortname": "XM",
		"name": "Man (Isle of)",
		"phonecode": "44"
	},
	{
		"id": "137",
		"sortname": "MH",
		"name": "Marshall Islands",
		"phonecode": "692"
	},
	{
		"id": "138",
		"sortname": "MQ",
		"name": "Martinique",
		"phonecode": "596"
	},
	{
		"id": "139",
		"sortname": "MR",
		"name": "Mauritania",
		"phonecode": "222"
	},
	{
		"id": "140",
		"sortname": "MU",
		"name": "Mauritius",
		"phonecode": "230"
	},
	{
		"id": "141",
		"sortname": "YT",
		"name": "Mayotte",
		"phonecode": "269"
	},
	{
		"id": "142",
		"sortname": "MX",
		"name": "Mexico",
		"phonecode": "52"
	},
	{
		"id": "143",
		"sortname": "FM",
		"name": "Micronesia",
		"phonecode": "691"
	},
	{
		"id": "144",
		"sortname": "MD",
		"name": "Moldova",
		"phonecode": "373"
	},
	{
		"id": "145",
		"sortname": "MC",
		"name": "Monaco",
		"phonecode": "377"
	},
	{
		"id": "146",
		"sortname": "MN",
		"name": "Mongolia",
		"phonecode": "976"
	},
	{
		"id": "147",
		"sortname": "MS",
		"name": "Montserrat",
		"phonecode": "1664"
	},
	{
		"id": "148",
		"sortname": "MA",
		"name": "Morocco",
		"phonecode": "212"
	},
	{
		"id": "149",
		"sortname": "MZ",
		"name": "Mozambique",
		"phonecode": "258"
	},
	{
		"id": "150",
		"sortname": "MM",
		"name": "Myanmar",
		"phonecode": "95"
	},
	{
		"id": "151",
		"sortname": "NA",
		"name": "Namibia",
		"phonecode": "264"
	},
	{
		"id": "152",
		"sortname": "NR",
		"name": "Nauru",
		"phonecode": "674"
	},
	{
		"id": "153",
		"sortname": "NP",
		"name": "Nepal",
		"phonecode": "977"
	},
	{
		"id": "154",
		"sortname": "AN",
		"name": "Netherlands Antilles",
		"phonecode": "599"
	},
	{
		"id": "155",
		"sortname": "NL",
		"name": "Netherlands The",
		"phonecode": "31"
	},
	{
		"id": "156",
		"sortname": "NC",
		"name": "New Caledonia",
		"phonecode": "687"
	},
	{
		"id": "157",
		"sortname": "NZ",
		"name": "New Zealand",
		"phonecode": "64"
	},
	{
		"id": "158",
		"sortname": "NI",
		"name": "Nicaragua",
		"phonecode": "505"
	},
	{
		"id": "159",
		"sortname": "NE",
		"name": "Niger",
		"phonecode": "227"
	},
	{
		"id": "160",
		"sortname": "NG",
		"name": "Nigeria",
		"phonecode": "234"
	},
	{
		"id": "161",
		"sortname": "NU",
		"name": "Niue",
		"phonecode": "683"
	},
	{
		"id": "162",
		"sortname": "NF",
		"name": "Norfolk Island",
		"phonecode": "672"
	},
	{
		"id": "163",
		"sortname": "MP",
		"name": "Northern Mariana Islands",
		"phonecode": "1670"
	},
	{
		"id": "164",
		"sortname": "NO",
		"name": "Norway",
		"phonecode": "47"
	},
	{
		"id": "165",
		"sortname": "OM",
		"name": "Oman",
		"phonecode": "968"
	},
	{
		"id": "166",
		"sortname": "PK",
		"name": "Pakistan",
		"phonecode": "92"
	},
	{
		"id": "167",
		"sortname": "PW",
		"name": "Palau",
		"phonecode": "680"
	},
	{
		"id": "168",
		"sortname": "PS",
		"name": "Palestinian Territory Occupied",
		"phonecode": "970"
	},
	{
		"id": "169",
		"sortname": "PA",
		"name": "Panama",
		"phonecode": "507"
	},
	{
		"id": "170",
		"sortname": "PG",
		"name": "Papua new Guinea",
		"phonecode": "675"
	},
	{
		"id": "171",
		"sortname": "PY",
		"name": "Paraguay",
		"phonecode": "595"
	},
	{
		"id": "172",
		"sortname": "PE",
		"name": "Peru",
		"phonecode": "51"
	},
	{
		"id": "173",
		"sortname": "PH",
		"name": "Philippines",
		"phonecode": "63"
	},
	{
		"id": "174",
		"sortname": "PN",
		"name": "Pitcairn Island",
		"phonecode": "0"
	},
	{
		"id": "175",
		"sortname": "PL",
		"name": "Poland",
		"phonecode": "48"
	},
	{
		"id": "176",
		"sortname": "PT",
		"name": "Portugal",
		"phonecode": "351"
	},
	{
		"id": "177",
		"sortname": "PR",
		"name": "Puerto Rico",
		"phonecode": "1787"
	},
	{
		"id": "178",
		"sortname": "QA",
		"name": "Qatar",
		"phonecode": "974"
	},
	{
		"id": "179",
		"sortname": "RE",
		"name": "Reunion",
		"phonecode": "262"
	},
	{
		"id": "180",
		"sortname": "RO",
		"name": "Romania",
		"phonecode": "40"
	},
	{
		"id": "181",
		"sortname": "RU",
		"name": "Russia",
		"phonecode": "70"
	},
	{
		"id": "182",
		"sortname": "RW",
		"name": "Rwanda",
		"phonecode": "250"
	},
	{
		"id": "183",
		"sortname": "SH",
		"name": "Saint Helena",
		"phonecode": "290"
	},
	{
		"id": "184",
		"sortname": "KN",
		"name": "Saint Kitts And Nevis",
		"phonecode": "1869"
	},
	{
		"id": "185",
		"sortname": "LC",
		"name": "Saint Lucia",
		"phonecode": "1758"
	},
	{
		"id": "186",
		"sortname": "PM",
		"name": "Saint Pierre and Miquelon",
		"phonecode": "508"
	},
	{
		"id": "187",
		"sortname": "VC",
		"name": "Saint Vincent And The Grenadines",
		"phonecode": "1784"
	},
	{
		"id": "188",
		"sortname": "WS",
		"name": "Samoa",
		"phonecode": "684"
	},
	{
		"id": "189",
		"sortname": "SM",
		"name": "San Marino",
		"phonecode": "378"
	},
	{
		"id": "190",
		"sortname": "ST",
		"name": "Sao Tome and Principe",
		"phonecode": "239"
	},
	{
		"id": "191",
		"sortname": "SA",
		"name": "Saudi Arabia",
		"phonecode": "966"
	},
	{
		"id": "192",
		"sortname": "SN",
		"name": "Senegal",
		"phonecode": "221"
	},
	{
		"id": "193",
		"sortname": "RS",
		"name": "Serbia",
		"phonecode": "381"
	},
	{
		"id": "194",
		"sortname": "SC",
		"name": "Seychelles",
		"phonecode": "248"
	},
	{
		"id": "195",
		"sortname": "SL",
		"name": "Sierra Leone",
		"phonecode": "232"
	},
	{
		"id": "196",
		"sortname": "SG",
		"name": "Singapore",
		"phonecode": "65"
	},
	{
		"id": "197",
		"sortname": "SK",
		"name": "Slovakia",
		"phonecode": "421"
	},
	{
		"id": "198",
		"sortname": "SI",
		"name": "Slovenia",
		"phonecode": "386"
	},
	{
		"id": "199",
		"sortname": "XG",
		"name": "Smaller Territories of the UK",
		"phonecode": "44"
	},
	{
		"id": "200",
		"sortname": "SB",
		"name": "Solomon Islands",
		"phonecode": "677"
	},
	{
		"id": "201",
		"sortname": "SO",
		"name": "Somalia",
		"phonecode": "252"
	},
	{
		"id": "202",
		"sortname": "ZA",
		"name": "South Africa",
		"phonecode": "27"
	},
	{
		"id": "203",
		"sortname": "GS",
		"name": "South Georgia",
		"phonecode": "0"
	},
	{
		"id": "204",
		"sortname": "SS",
		"name": "South Sudan",
		"phonecode": "211"
	},
	{
		"id": "205",
		"sortname": "ES",
		"name": "Spain",
		"phonecode": "34"
	},
	{
		"id": "206",
		"sortname": "LK",
		"name": "Sri Lanka",
		"phonecode": "94"
	},
	{
		"id": "207",
		"sortname": "SD",
		"name": "Sudan",
		"phonecode": "249"
	},
	{
		"id": "208",
		"sortname": "SR",
		"name": "Suriname",
		"phonecode": "597"
	},
	{
		"id": "209",
		"sortname": "SJ",
		"name": "Svalbard And Jan Mayen Islands",
		"phonecode": "47"
	},
	{
		"id": "210",
		"sortname": "SZ",
		"name": "Swaziland",
		"phonecode": "268"
	},
	{
		"id": "211",
		"sortname": "SE",
		"name": "Sweden",
		"phonecode": "46"
	},
	{
		"id": "212",
		"sortname": "CH",
		"name": "Switzerland",
		"phonecode": "41"
	},
	{
		"id": "213",
		"sortname": "SY",
		"name": "Syria",
		"phonecode": "963"
	},
	{
		"id": "214",
		"sortname": "TW",
		"name": "Taiwan",
		"phonecode": "886"
	},
	{
		"id": "215",
		"sortname": "TJ",
		"name": "Tajikistan",
		"phonecode": "992"
	},
	{
		"id": "216",
		"sortname": "TZ",
		"name": "Tanzania",
		"phonecode": "255"
	},
	{
		"id": "217",
		"sortname": "TH",
		"name": "Thailand",
		"phonecode": "66"
	},
	{
		"id": "218",
		"sortname": "TG",
		"name": "Togo",
		"phonecode": "228"
	},
	{
		"id": "219",
		"sortname": "TK",
		"name": "Tokelau",
		"phonecode": "690"
	},
	{
		"id": "220",
		"sortname": "TO",
		"name": "Tonga",
		"phonecode": "676"
	},
	{
		"id": "221",
		"sortname": "TT",
		"name": "Trinidad And Tobago",
		"phonecode": "1868"
	},
	{
		"id": "222",
		"sortname": "TN",
		"name": "Tunisia",
		"phonecode": "216"
	},
	{
		"id": "223",
		"sortname": "TR",
		"name": "Turkey",
		"phonecode": "90"
	},
	{
		"id": "224",
		"sortname": "TM",
		"name": "Turkmenistan",
		"phonecode": "7370"
	},
	{
		"id": "225",
		"sortname": "TC",
		"name": "Turks And Caicos Islands",
		"phonecode": "1649"
	},
	{
		"id": "226",
		"sortname": "TV",
		"name": "Tuvalu",
		"phonecode": "688"
	},
	{
		"id": "227",
		"sortname": "UG",
		"name": "Uganda",
		"phonecode": "256"
	},
	{
		"id": "228",
		"sortname": "UA",
		"name": "Ukraine",
		"phonecode": "380"
	},
	{
		"id": "229",
		"sortname": "AE",
		"name": "United Arab Emirates",
		"phonecode": "971"
	},
	{
		"id": "230",
		"sortname": "GB",
		"name": "United Kingdom",
		"phonecode": "44"
	},
	{
		"id": "231",
		"sortname": "US",
		"name": "United States",
		"phonecode": "1"
	},
	{
		"id": "232",
		"sortname": "UM",
		"name": "United States Minor Outlying Islands",
		"phonecode": "1"
	},
	{
		"id": "233",
		"sortname": "UY",
		"name": "Uruguay",
		"phonecode": "598"
	},
	{
		"id": "234",
		"sortname": "UZ",
		"name": "Uzbekistan",
		"phonecode": "998"
	},
	{
		"id": "235",
		"sortname": "VU",
		"name": "Vanuatu",
		"phonecode": "678"
	},
	{
		"id": "236",
		"sortname": "VA",
		"name": "Vatican City State (Holy See)",
		"phonecode": "39"
	},
	{
		"id": "237",
		"sortname": "VE",
		"name": "Venezuela",
		"phonecode": "58"
	},
	{
		"id": "238",
		"sortname": "VN",
		"name": "Vietnam",
		"phonecode": "84"
	},
	{
		"id": "239",
		"sortname": "VG",
		"name": "Virgin Islands (British)",
		"phonecode": "1284"
	},
	{
		"id": "240",
		"sortname": "VI",
		"name": "Virgin Islands (US)",
		"phonecode": "1340"
	},
	{
		"id": "241",
		"sortname": "WF",
		"name": "Wallis And Futuna Islands",
		"phonecode": "681"
	},
	{
		"id": "242",
		"sortname": "EH",
		"name": "Western Sahara",
		"phonecode": "212"
	},
	{
		"id": "243",
		"sortname": "YE",
		"name": "Yemen",
		"phonecode": "967"
	},
	{
		"id": "244",
		"sortname": "YU",
		"name": "Yugoslavia",
		"phonecode": "38"
	},
	{
		"id": "245",
		"sortname": "ZM",
		"name": "Zambia",
		"phonecode": "260"
	},
	{
		"id": "246",
		"sortname": "ZW",
		"name": "Zimbabwe",
		"phonecode": "263"
	}
]''';

Future<List<Country>> countries() => compute(_parseCountries, _countries);

List<Country> _parseCountries(String countries) {
  return (json.decode(countries) as List)
      .map((dynamic c) =>
          Country(c['name'] as String, int.parse(c['id'] as String)))
      .toList();
}

class Country extends Equatable {
  const Country(this.name, this.id);
  final String name;
  final int id;

  @override
  List<Object> get props => [name, id];
}
