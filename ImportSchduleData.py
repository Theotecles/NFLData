# IMPORT PACKAGES NEEDED

import pyodbc as dbc
import pandas as pd

# SET UP SQL CONNECTION

con = dbc.connect('Driver={SQL Server};'
                  'Server=*****'
                  'Database=*****;'
                  'UID=*****;'
                  'PWD=*****;')

cursor = con.cursor()

# IMPORT CSV FILE INTO PYTHON

scores = pd.read_csv(r'E:\NFLDataProject\Local\CSVFiles\RawData\schedule.csv')

print(scores.head())

for row in scores.itertuples():
    cursor.execute('''
                INSERT INTO NFLDATABASE1.dbo.schedule (Sort,
                                                       Game_ID,
                                                       Season,
                                                       Game_Type,
                                                       Game_Week,
                                                       Game_Date,
                                                       Week_Day,
                                                       Start_Time,
                                                       Away_Team,
                                                       Home_Team,
                                                       Stadium,
                                                       Neutral,
                                                       Old_Game_Id)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
                ''',
                row.sort, 
                row.game_id,
                row.season,
                row.game_type,
                row.week,
                row.gameday,
                row.weekday,
                row.gametime,
                row.away_team,
                row.home_team,
                row.stadium,
                row.location,
                row.old_game_id
                )
con.commit()
