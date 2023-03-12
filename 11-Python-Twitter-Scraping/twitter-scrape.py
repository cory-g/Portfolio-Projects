import snscrape.modules.twitter as sntwitter
import pandas as pd
import datetime

today = str(datetime.date.today())

def scrape_user():

    attributes_container = []
    username = input('Enter the Twitter Username: @')
    max_tweets = int(input('Number of Tweets to collect: '))

    # Using TwitterSearchScraper to scrape data and append tweets to list
    for i, tweet in enumerate(sntwitter.TwitterSearchScraper('from:'+username).get_items()):
        # Set MAX number of tweets to scrape
        if i > max_tweets - 1:
            break
        attributes_container.append(
            [tweet.user.username, tweet.date, tweet.likeCount, tweet.sourceLabel, tweet.rawContent])

    # Creating a dataframe from the tweets list above
    df = pd.DataFrame(attributes_container,
                      columns=['Username', 'Date Created', 'Number of Likes', 'Source of Tweet', 'Tweets'])

    print(df)

    num_tweets = str(df.shape[0])
    df.to_csv(username + '_' + num_tweets + '-tweets_' + today + '.csv', index=False)
#    df.to_csv(username + '_tweets_' + today + '.csv', index=False)

    print(f'\nOutput written to: {username}_{num_tweets}-tweets_{today}.csv')


def scrape_criteria():

    attributes_container = []
    subject = input('Enter the Text to Search for: ')
    start_date = input('Enter Starting Date Range (yyyy-mm-dd): ')
    end_date = input('Enter Ending Date Range (yyyy-mm-dd): ')
    max_tweets = int(input('Number of Tweets to collect: '))

    # Using TwitterSearchScraper to scrape data and append tweets to list
    for i, tweet in enumerate(
            sntwitter.TwitterSearchScraper(subject+' since:'+start_date+' until:'+end_date).get_items()):
        # Set MAX number of tweets to scrape
        if i > max_tweets - 1:
            break
        attributes_container.append(
            [tweet.user.username, tweet.date, tweet.likeCount, tweet.sourceLabel, tweet.rawContent])

    # Creating a dataframe to load the list
    df = pd.DataFrame(attributes_container,
                      columns=['Username', 'Date Created', 'Number of Likes', 'Source of Tweet', 'Tweet'])

    print(df)

    num_tweets = str(df.shape[0])
    new_subject = subject.replace(" ", "_")
    df.to_csv(new_subject + '_' + num_tweets + '-tweets_' + today + '.csv', index=False)

    print(f'\nOutput written to: {new_subject}_{num_tweets}-tweets_{today}.csv')


while True:

    user_option = input("\nScrape Tweets by Username or Subject? Enter 'u' or 's': ").upper()
    if user_option == 'U':
        scrape_user()
    else:
        scrape_criteria()

    scrape_again = input("\nDo you want to Scrape again? 'y' or 'n': ").upper()
    if scrape_again == 'Y':
        continue
    else:
        break
