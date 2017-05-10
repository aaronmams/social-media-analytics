# -*- coding: utf-8 -*-
"""
Created on Tue May  9 21:32:45 2017

@author: aaronmamula
"""

#---------------------------------------------
#first pass to get a list of my friends

import facebook
import requests

tok = 'EAACEdEose0cBAK6qZChvQT8R11IHQdSwPuke9CfEkdZAAtkdZCgzlho9ZALlwk3RkfN8ahGIVN0s69Fs18l2CKt6p4gK2Wx76zkXyNuLYCdyOLIkGw0ZCWzML7Ktj2fL71uu61tOHPWmT6eO8XB3r51XaICeb3eW80ZA2FMA1FSt5ekQ3PJFQB'

#c44c1f85f116e25f6f7042f08ef98341
#user = 'Aaron Mamula'

graph = facebook.GraphAPI(tok)


#----------------------------------------------------
#try to get info for brand page

def some_action(post):
    """ Here you might want to do something with each post. E.g. grab the
    post's message (post['message']) or the post's picture (post['picture']).
    In this implementation we just print the post's created time.
    """
    print(post['likes'])


user = 'UCSCMensSoccer'
profile = graph.get_object(user)
posts = graph.get_connections(profile['id'], 'posts',limit=5)

#apply the function 'some_action' to the posts from the UCSC account
while True:
    try:
        # Perform some action on each post in the collection we receive from
        # Facebook.
        [some_action(post=post) for post in posts['data']]
        # Attempt to make a request to the next page of data, if it exists.
        posts = requests.get(posts['paging']['next']).json()
    except KeyError:
        # When there are no more pages (['paging']['next']), break from the
        # loop and end the script.
        break


#Next Steps
#1. can we get save the meta-data in a list rather than printing to screen?
#2. with that list can we extract just the names of people that have liked any of our posts?
#-------------------------------------------------------------------------


#a different way
lks = graph.get_connections(profile['id'], connection_name='likes')

for like in lks['data']:
    print(like['name'])
    
#----------------------------------------------------

#-----------------------------------------------------
