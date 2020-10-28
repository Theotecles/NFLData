# IMPORT PACKAGES NEEDED

import pyodbc as dbc
import pandas as pd

# SET UP SQL CONNECTION

con = dbc.connect('Driver={SQL Server};'
                  'Server=nfldatabase1.ckriwyveewcw.us-east-2.rds.amazonaws.com,1433;'
                  'Database=NFLDATABASE1;'
                  'UID=admin;'
                  'PWD=MBDiJ81994!;')

cursor = con.cursor()

# IMPORT CSV FILE INTO PYTHON

scores = pd.read_csv(r'E:\NFLDataProject\CSVFiles\scores.csv')

print(scores.head())

for row in scores.itertuples():
    cursor.execute('''
                INSERT INTO NFLDATABASE1.dbo.scores (Sort,
                                                     Game_ID,
                                                     Season,
                                                     Game_Type,
                                                     Game_Week,
                                                     Game_Date,
                                                     Week_Day,
                                                     Start_Time,
                                                     Away_Team,
                                                     Home_Team,
                                                     Away_Score,
                                                     Home_Score,
                                                     Home_Result,
                                                     Stadium,
                                                     Neutral,
                                                     Old_Game_Id)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
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
                row.away_score,
                row.home_score,
                row.home_result,
                row.stadium,
                row.location,
                row.old_game_id
                )
con.commit()
