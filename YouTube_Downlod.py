#import the package
from pytube import YouTube
#The URL of the YoutTube video we wish to download
url = ''
video = YouTube(url)
#Here we will ensure the correct video title
print("Video Title: ")
print(video.title)
#Here we will ensure the correct video thumbnail image
print("Thumbnail Image: ")
print(video.thumbnail_url)
#Here we will set the resolution for which we want our download to posses
video = video.streams.get_highest_resolution()
#Finally we will downlaod the video that corrisponds to the URL we place above
video.download()




