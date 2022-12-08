# Setting Up My Environment
library(tidyverse)
library(skimr)
library(janitor)
library(gridExtra)
spinrate <- read_csv("~/Documents/Data-Analysis/Github/Portfolio-Projects/01-MLB-Spinrate-Data-in-R/MLB_Musgrove-Joe_Reg-Post-Season_Pitch-Data.csv")


################################################################################

# Looking at Spin Rate Data


# Average Spin Rates by Season, Pitch Type
avg_spin <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  summarize(avg_spinrate = format(round(mean(release_spin_rate), 2), nsmall=2)) %>% 
  arrange(desc(season_type))
avg_spin


# Scatter Plot: Average Spin Rate by Pitch, Regular vs Post Season  
ggplot(avg_spin, aes(pitch_name, avg_spinrate, color = season_type)) +
  geom_point(size = 4, shape = 9) +
  labs(title='Average Spin Rate, Pitch', subtitle='Regular Season vs Post Season',
       color='Season Type', x='Type of Pitch', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com') +
  annotate('text', x=5.3, y=11, label='Slider Had the') +
  annotate('text', x=5.3, y=10.6, label='Largest Increase')

  
# Column Chart: Average Spin Rate by Pitch, Regular vs Post Season
ggplot(avg_spin, aes(pitch_name, avg_spinrate, fill = season_type)) +
  geom_col(position = "dodge") +
  labs(title='Average Spin Rate, Pitch', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Type of Pitch', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com')


# Average Spin Rate, Filtered by Pitch
spinrate %>% 
  group_by(season_type, pitch_name) %>%
  filter(pitch_name == 'Slider') %>% 
  summarize(avg_spinrate = mean(release_spin_rate)) %>% 
  arrange(desc(season_type))


################################################################################

# Looking at Pitch Speed Data


# Average Pitch Speed by Season, Pitch Type
avg_speed <- spinrate %>% 
  group_by(season_type, pitch_name) %>% 
  summarize(average_mpg = format(round(mean(effective_speed, na=TRUE), 2), nsmall=2)) %>% 
  arrange(desc(season_type))
avg_speed


# Scatter Plot: Average MPH by Pitch, Regular vs Post Season
ggplot(avg_speed, aes(pitch_name, average_mpg, color = season_type)) +
  geom_point(size = 4) +
  labs(title='Average Speed MPH, Pitch', subtitle='Regular Season vs Post Season',
       color='Season Type', x='Type of Pitch', y='Average Speed, MPH',
       caption='Data Gathered from baseballsavant.mlb.com')


# Column Chart: Average MPG by Pitch, Regular vs Post Season
ggplot(avg_speed, aes(pitch_name, average_mpg, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='Average Speed MPH, Pitch', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Type of Pitch', y='Average Speed, MPH',
       caption='Data Gathered from baseballsavant.mlb.com')


# Average Pitch Speed, Filtered by Pitch
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


# With Two-Outs: Thrown for Strikeout by Pitch, Regular vs Post Season
thrown_2out <- spinrate %>% 
  group_by(season_type, pitch_name) %>%
  filter(strikes == 2) %>%
  summarize(strikeouts = sum(at_bat_outcome == 'strikeout', na.rm=TRUE),
            times_thrown_2out = sum(strikes == 2),
            strikeout_pct = format(round((strikeouts/times_thrown_2out)*100, 2), nsmall=2)) %>%
  arrange(desc(season_type)) 
thrown_2out


# Scatter plot: With Two-Outs: Thrown for Strikeout by Pitch, Regular vs Post Season
ggplot(thrown_2out, aes(pitch_name, strikeout_pct, color = season_type)) +
  geom_point(size = 4) +
  labs(title='With Two-Outs: Thrown for Strikeout, Pitch', subtitle='Regular Season vs Post Season',
       color='Season Type', x='Type of Pitch', y='Strikeout Percentage',
       caption='Data Gathered from baseballsavant.mlb.com') +
  annotate('text', x=5.3, y=11, label='Slider Was The') +
  annotate('text', x=5.3, y=10.6, label='Only Increase')


# Column Chart: With Two-Outs: Thrown for Strikeout by Pitch, Regular vs Post Season
ggplot(thrown_2out, aes(pitch_name, strikeout_pct, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='With Two-Outs: Thrown for Strikeout, Pitch', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Type of Pitch', y='Strikeout Percentage',
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
            times_thrown_2out = sum(strikes == 2),
            strikeout_pct = format(round((strikeouts/times_thrown_2out)*100, 2), nsmall=2)) %>%
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
  labs(title='With Two-Outs: Thrown for Strikeout, Slider', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Slider, Pitch Thrown', y='Strikeout Percentage',
       caption='Data Gathered from baseballsavant.mlb.com')

plot2 <- ggplot(slider_sr, aes(pitch_name, avg_spinrate, fill = season_type)) +
  geom_col(position = 'dodge') +
  labs(title='Average Spinrate, Slider', subtitle='Regular Season vs Post Season',
       fill='Season Type', x='Slider, Pitch Thrown', y='Average Spinrate',
       caption='Data Gathered from baseballsavant.mlb.com')


# Combining the Two Graphs Side-by-Side
grid.arrange(plot1, plot2, ncol=2)

