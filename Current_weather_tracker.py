#import the package
import requests
API_WeatherKey = '70c47ee488ab5a0e71e49ce00317c6f0'

#Now we need the URL which our request will be made from:
URL = "https://api.openweathermap.org/data/2.5/weather"

#Next we will creat an input for users to select a city:
city = input("Enter a city name: ")

#Next we will creat a get request since we are reciving data:
requests_url = f"{URL}?appid={API_WeatherKey}&q={city}"
response = requests.get(requests_url)

'''Because there is a chance of error we will check for correct status code
and print the specific data we are searching for: '''
if response.status_code == 200:
    data = response.json()
    weather = data['weather'][0]['description']
    print("Current Condition: ", weather)
    temperature = round(data["main"]["temp"] - 273.15 , 0)
    print("Current Tempature in Celcius: ", temperature)
else:
    print("Error Occured")

