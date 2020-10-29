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

odds = pd.read_csv(r'E:\NFLDataProject\Local\CSVFiles\RawData\nflodds.csv')

for row in odds.itertuples():
    cursor.execute('''
                INSERT INTO NFLDATABASE1.dbo.Odds (Sort,
                                                   Game_Id,
                                                   Home_Team,
                                                   Away_Team,
                                                   Favorite,
                                                   Underdog,
                                                   Spread,
                                                   Total,
                                                   Season,
                                                   Game_Week,
                                                   Odds_Favorite,
                                                   Odds_Underdog,
                                                   Money_Line_Favorite,
                                                   Money_Line_Underdog,
                                                   Odds_Over,
                                                   Odds_Under)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                ''',
                row.Sort, 
                row.Game_ID,
                row.Home_Team,
                row.Away_Team,
                row.Favorite,
                row.Underdog,
                row.Spread,
                row.Total,
                row.Season,
                row.Week,
                row.Odds_Favorite,
                row.Odds_Underdog,
                row.Money_Line_Favorite,
                row.Money_Line_Underdog,
                row.Odds_Over,
                row.Odds_Under
                )
con.commit()
