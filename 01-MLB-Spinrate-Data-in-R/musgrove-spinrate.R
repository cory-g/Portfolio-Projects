# Setting Up My Environment
library(tidyverse)
library(skimr)
library(janitor)
library(gridExtra)
spinrate <- read_csv("~/Documents/Data-Analysis/Github/Portfolio-Projects/01-MLB-Spinrate-Data-in-R/MLB_Musgrove-Joe_Reg-Post-Season_Pitch-Data.csv")


################################################################################

# Looking at Spinrate Data, Game in Question (10/09/22)

# Game in Question: Looking at Spinrates, Regular Season vs  Post Season Mets Game (10/09/22)
reg_slider_sr <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  filter(season_type == 'Regular Season') %>% 
  summarize(avg_spinrate = format(round(mean(release_spin_rate), 2), nsmall=2))
reg_slider_sr

mets_slider_sr <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  filter(game_date == '10/9/2022') %>% 
  summarize(avg_spinrate = format(round(mean(release_spin_rate), 2), nsmall=2))
mets_slider_sr

comb <- data.frame(reg_slider_sr, mets_slider_sr)

# Finding the Spinrate increase during the Mets Post Season Game (10/09/2022)
comb <- comb %>% 
  mutate(increase_spinrate=as.numeric(avg_spinrate.1)-as.numeric(avg_spinrate))
comb


# Graphing the above Spinrates
ggplot(comb) + 
  geom_point(aes(pitch_name, avg_spinrate, color = season_type)) +
  geom_point(aes(pitch_name.1, avg_spinrate.1, color = season_type.1)) +
  labs(title='Average Spinrate', subtitle='Regular Season vs Post Season Mets Game (10/09/22)',
       color='Season Type', x='Pitch Thrown', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com') +
  annotate('text', x=5.3, y=10.5, label='+249.19 RPM', color = 'red') +
  annotate('text', x=2.3, y=10.5, label='+171.15 RPM') +
  annotate('text', x=1.6, y=5.9, label='+106.71 RPM') +
  annotate('text', x=2.6, y=1.5, label='+176.64 RPM') +
  annotate('text', x=4.6, y=6.9, label='+116.67 RPM') +
  annotate('text', x=5.6, y=3.4, label='+105.55 RPM')


################################################################################

# Looking at Spinrate Data, Regular vs Post Season

# Average Spinrates by Pitch, Regular vs Post Season
avg_spin <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  summarize(avg_spinrate = format(round(mean(release_spin_rate), 2), nsmall=2)) %>% 
  arrange(desc(season_type))
avg_spin


# Scatter Plot: Average Spinrate by Pitch, Regular vs Post Season  
ggplot(avg_spin, aes(pitch_name, avg_spinrate, color = season_type)) +
  geom_point(size = 4, shape = 9) +
  labs(title='Average Spinrate', subtitle='Regular Season vs Post Season',
       color='Season Type', x='Pitch Thrown', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com') +
  annotate('text', x=5.3, y=10.5, label='+192.60 RPM', color = 'red') +
  annotate('text', x=2.3, y=10.5, label='+116.26 RPM') +
  annotate('text', x=1.6, y=5.9, label='+90.31 RPM') +
  annotate('text', x=2.6, y=1.5, label='+101.95 RPM') +
  annotate('text', x=4.6, y=6.9, label='+83.30 RPM') +
  annotate('text', x=5.6, y=3.4, label='+79.35 RPM')


# Column Chart: Average Spinrate by Pitch, Regular vs Post Season
ggplot(avg_spin, aes(pitch_name, avg_spinrate, fill = season_type)) +
  geom_col(position = "dodge") +
  labs(title='Average Spinrate', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Pitch Thrown', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com')


# Average Spinrate, Filtered by Pitch
spinrate %>% 
  group_by(season_type, pitch_name) %>%
  filter(pitch_name == 'Slider') %>% 
  summarize(avg_spinrate = mean(release_spin_rate)) %>% 
  arrange(desc(season_type))


################################################################################

# Looking at Pitch Speed Data


# Average Speed MPH by Pitch, Regular vs Post Season
avg_speed <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  summarize(average_mph = format(round(mean(effective_speed, na=TRUE), 2), nsmall=2)) %>% 
  arrange(desc(season_type))
avg_speed


# Scatter Plot: Average Speed MPH by Pitch, Regular vs Post Season
ggplot(avg_speed, aes(pitch_name, average_mph, color = season_type)) +
  geom_point(size = 4) +
  labs(title='Average Pitch Speed, MPH', subtitle='Regular Season vs Post Season',
       color='Season Type', x='Pitch Thrown', y='Average Speed, MPH',
       caption='Data Gathered from baseballsavant.mlb.com')


# Column Chart: Average Speed MPH by Pitch, Regular vs Post Season
ggplot(avg_speed, aes(pitch_name, average_mph, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='Average Pitch Speed, MPH', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Pitch Thrown', y='Average Speed, MPH',
       caption='Data Gathered from baseballsavant.mlb.com')


# Average Speed MPH, Filtered by Pitch
spinrate %>% 
  group_by(season_type, pitch_name) %>%
  filter(pitch_name == 'Slider') %>% 
  summarize(average_mph = mean(effective_speed, na=TRUE)) %>% 
  arrange(desc(season_type))

################################################################################

# Looking at Strikeouts by Pitch, Regular vs Post Season


# Total Strikeouts by Pitch, Regular vs Post Season
strikeouts <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  filter(at_bat_outcome == 'strikeout') %>% 
  summarize(strikeouts = sum(at_bat_outcome == 'strikeout')) %>%
  arrange(desc(season_type))
strikeouts


# With Two Strikes: Percent Thrown for Strikeout by Pitch, Regular vs Post Season
two_strikes <- spinrate %>% 
  group_by(season_type, pitch_name) %>%
  filter(strikes == 2) %>%
  summarize(strikeouts = sum(at_bat_outcome == 'strikeout', na.rm=TRUE),
            times_thrown_2strikes = sum(strikes == 2),
            strikeout_pct = format(round((strikeouts/times_thrown_2strikes)*100, 2), nsmall=2)) %>%
  arrange(desc(season_type)) 
two_strikes


# Scatter plot: With Two Strikes: Percent Thrown for Strikeout by Pitch, Regular vs Post Season
ggplot(two_strikes, aes(pitch_name, strikeout_pct, color = season_type)) +
  geom_point(size = 4) +
  labs(title='With Two Strikes: Percent Thrown for Strikeout', subtitle='Regular Season vs Post Season',
       color='Season Type', x='Pitch Thrown', y='Strikeout Percentage',
       caption='Data Gathered from baseballsavant.mlb.com') +
  annotate('text', x=5.3, y=11, label='Slider Was The') +
  annotate('text', x=5.3, y=10.6, label='Only Increase')


# Column Chart: With Two Strikes: Percent Thrown for Strikeout by Pitch, Regular vs Post Season
ggplot(two_strikes, aes(pitch_name, strikeout_pct, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='With Two Strikes: Percent Thrown for Strikeout', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Pitch Thrown', y='Strikeout Percentage',
       caption='Data Gathered from baseballsavant.mlb.com') +
  annotate('text', x=5.3, y=11, label='Slider Was The') +
  annotate('text', x=5.3, y=10.6, label='Only Increase')


###############################################################################

# Looking at Slider Data


# Slider Strikeout Data
slider_strike <- spinrate %>% 
  group_by(season_type, pitch_name) %>%
  filter(strikes == 2, pitch_name == 'Slider') %>%
  summarize(strikeouts = sum(at_bat_outcome == 'strikeout', na.rm=TRUE),
            times_thrown_2strikes = sum(strikes == 2),
            strikeout_pct = format(round((strikeouts/times_thrown_2strikes)*100, 2), nsmall=2)) %>%
  arrange(desc(season_type))
slider_strike


# Slider Spinrate Data
slider_sr <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  filter(pitch_name == 'Slider') %>% 
  summarize(avg_spinrate = format(round(mean(release_spin_rate), 2), nsmall=2)) %>% 
  arrange(desc(season_type))
slider_sr


# Plotting Strikeout & Spinrate Data
plot1 <- ggplot(slider_strike, aes(pitch_name, strikeout_pct, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='Two Strikes: Strikeout Percentage', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Pitch Thrown', y='Strikeout Percentage',
       caption='Data Gathered from baseballsavant.mlb.com')

plot2 <- ggplot(slider_sr, aes(pitch_name, avg_spinrate, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='Average Spinrate, Slider', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Pitch Thrown', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com')


# Combining the Two Graphs Side-by-Side
grid.arrange(plot1, plot2, ncol=2)