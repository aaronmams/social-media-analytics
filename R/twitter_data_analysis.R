
require(twitteR)

#Twitter credentials

#pw: Nmfsswfsc2016#
#username: aaronmams
#email: aaron.mams@gmail.com
#app name: mamultron
#owner: mamulsaurus
#owner id: 750554190489985025


# consumer key:
# c71wImbS4aZnwA0yKx14Z5cxz

# consumer secret
#HfRuYxKvAoXuTwTwUa9vslKlsB3AL5kQLv40U12Xsxz1ybkhuX

# access token
#750554190489985025-aOkEUbRXEXeyaKpHmM2VX5ZJ7WhoM7j

#access token secret
# 66o8C4tzc8LaqZNCE1XoJDU4QLFyPXu2qlUk3JlHBxd71

consumer_key <- 'c71wImbS4aZnwA0yKx14Z5cxz'
consumer_secret <- 'HfRuYxKvAoXuTwTwUa9vslKlsB3AL5kQLv40U12Xsxz1ybkhuX'
access_token <- '750554190489985025-aOkEUbRXEXeyaKpHmM2VX5ZJ7WhoM7j'
access_secret <- '66o8C4tzc8LaqZNCE1XoJDU4QLFyPXu2qlUk3JlHBxd71'
  
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

#------------------------------------------------------------------------------
#simple starter exercise:

# 1. pull twitter data on NOAA Fisheries tweets
# 2. who retweets NOAA science tweets
# 2A. where are they
# 2B. 
require(data.table)
require(ggplot2)
require(ggmap)
require(stringr)
require(tm)

noaa <- getUser("NOAAFisheries")
location(noaa)

#noaa_follower_IDs<-noaa$getFollowers(retryOnRateLimit=180)
noaa_follower_IDs<-noaa$getFollowers()
length(noaa_follower_IDs)
noaa_followers_df = rbindlist(lapply(noaa_follower_IDs,as.data.frame))

#remove followers that don't report a location
noaa_followers_df<-subset(noaa_followers_df, location!="")

# remove any instances of %
noaa_followers_df$location<-gsub("%", " ",noaa_followers_df$location)

#I also want to remove locations that I know geocode() won't be able to parse
# starting with anything with piping ("|")
#noaa_followers_df$location<-gsub("|", " ",noaa_followers_df$location)

#remove users whose location is some variation of USA
# returns string w/o leading or trailing whitespace
#trim <- function (x) gsub("^\\s+|\\s+$", "", x)
#trim(noaa_followers_df$location[1:200])

noaa_followers_df$location <- str_trim(noaa_followers_df$location,side='both')

noaa_followers_df <- noaa_followers_df[!noaa_followers_df$location %in% c("USA","U.S.A","United States",
                                                                          "UNITED STATES")]

#confine this example to a randomly sampled 2000 followers...this is because the 
# geocode() function from the ggmap package only allows you to ping the API 2,500 times
# unless you sign on as a developer...I don't want to mess with that at the moment so I'm
# just going to get a sample
geo <- function(i){
l <- noaa_followers_df$location[i]
loc <- geocode(l,output='all')

#error handling
if(is.na(loc)==T){
  d.tmp <- data.frame(lat=NA,long=NA) 
}else if(loc$status=='OK'){

    if(length(loc[[1]])==1){
      lat.tmp <- loc[[1]]
      lat.tmp <- lat.tmp[[1]]$geometry
      lat <- lat.tmp$location$lat
      long <- lat.tmp$location$lng
      d.tmp <- data.frame(lat=lat,long=long)
  
    }else{
      d.tmp <- data.frame(lat=NA,long=NA)  
    
    }
}else{
  d.tmp <- data.frame(lat=NA,long=NA)  
}
return(d.tmp)
}

t <- Sys.time()
follwer.geo <- lapply(c(101:500),geo)
Sys.time() - t

noaa.follower.geo <- data.frame(rbindlist(follwer.geo))

#going to split this up in case the batch geocoding routine fails
tmp1 <- cbind(noaa_followers_df$location[101:500],noaa.follower.geo)
tmp <- cbind(noaa_followers_df$location[1:100],noaa.follower.geo)
names(tmp) <- c('location','lat','long')
names(tmp1) <- c('location','lat','long')
tmp <- rbind(tmp,tmp1)

#now dump the lat/long from the tmp dataframe into ggmap and display a point for
#each user
map <- get_map(location = 'USA', zoom = 4)
ggmap(map) +
  geom_point(aes(x = long, y = lat), data = tmp, alpha = .5, size=3)




#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#next step we want to see what the users who follow a certain account 
# (like @NOAAFisheries) tend to tweet about.  For this, we'll get the followers 
# for a user and then pull tweets from those users to see what they tend to tweet
# about
noaa.hab = searchTwitter('from:NOAAHabitat',n=3000)

#get Ryan Mac's followers
nmac <- getUser('Rmac18')
nmac_followers <- nmac$getFollowers()
nmac_followers = rbindlist(lapply(nmac_followers,as.data.frame))

follower_tweets <- searchTwitter('from:@PaulTassi',n=100)
ft = twListToDF(follower_tweets)

#use some functions in the 'tm' package to count the occurrances of each word in
# PaulTassi's tweets
mac.text <- paste(ft$text, collapse=" ")
review_source <- VectorSource(mac.text)

#use some of tm's built in functions to clean the text data
corpus <- Corpus(review_source)
corpus <- tm_map(corpus, content_transformer(tolower))

corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords(“english”)
  
nmac = searchTwitter('@realDonaldTrump',n=3000)
dt <- twListToDF(trump_tweets)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

nbahash_tweets = searchTwitter("#nba",n=3000)
d = twListToDF(nbahash_tweets)

userInfo <- lookupUsers(d$screenName[1:10])  # Batch lookup of user info
userFrame <- twListToDF(userInfo)  # Convert to a nice dF
