import json
from os import path

#Function that creates files and populates the JSON Elements in them
def createNewFile(jsonElement, fileName):
	with open(fileName, 'w') as newJsonFile:
		json.dump(jsonElement, newJsonFile, indent = 2)

#Declaring Variables
fileName = 'movie.json'
listObj = []

# Check if file exists
if path.isfile(fileName) is False:
  raise Exception("File not found")

#Read JSON file
with open('movie.json', encoding='utf8') as JSONFile:
	data = json.load(JSONFile)
counter = 0
fileNameCounter = 1
fileName = 'NewJsonFile'
newJsonElement = {
	"movie":[]
}
elementCounter = 0
for movie in data['movie']:
	#We selected 1150, becuase that way we will have 8 files
	if(counter < 1150):
		listObj.append(movie)
		print(movie)
		print(counter)
		counter += 1
	else:
		print(counter)
		createNewFile(listObj, fileName + str(fileNameCounter) + '.json')
		fileNameCounter +=1
		counter = 0
		listObj = []
