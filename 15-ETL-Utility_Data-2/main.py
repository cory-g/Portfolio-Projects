import pandas as pd
import numpy as np
import os
import glob
import datetime as dt
import shutil


## Setting variables
# Folder containing original csv files
folder_path = r"C:\Users\Data"

# Location of file to be copied into every folder
val_file = os.path.join(folder_path, "Validation_Template.xlsm")

# Name of the folder to be created in every folder
val_folder_date = '2025_03_10-Validation-'

# Earliest date when filtering transformed data
util_date = '01/01/2025'

# Store all XLSX files
xlsx_files = sorted(glob.glob(os.path.join(f'{folder_path}', "*.xlsx")))
files_remain = len(xlsx_files)


# Create a folder for every XLSX file being transformed
def create_folder(directory):
    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)

        if os.path.isfile(file_path):
            folder_name = os.path.splitext(file_name)[0]
            new_folder_path = os.path.join(directory, folder_name)
            os.makedirs(new_folder_path, exist_ok=True)

    print('Folders created')

# Read XLSX file
def load_xlsx(file_path):
    df = pd.read_excel(file_path, parse_dates=[1], header=0)
    return df

# Transform and filter the data
def transform(df_orig, file_name):
    df_orig = df_orig.drop(df_orig.columns[26], axis=1)
    df_select = df_orig.drop(df_orig.columns[0], axis=1)

    df_select.rename(
        columns={df_select.columns[1]: "00:00", df_select.columns[2]: "01:00", df_select.columns[3]: "02:00",
                 df_select.columns[4]: "03:00", df_select.columns[5]: "04:00", df_select.columns[6]: "05:00",
                 df_select.columns[7]: "06:00", df_select.columns[8]: "07:00", df_select.columns[9]: "08:00",
                 df_select.columns[10]: "9:00", df_select.columns[11]: "10:00", df_select.columns[12]: "11:00",
                 df_select.columns[13]: "12:00", df_select.columns[14]: "13:00", df_select.columns[15]: "14:00",
                 df_select.columns[16]: "15:00", df_select.columns[17]: "16:00", df_select.columns[18]: "17:00",
                 df_select.columns[19]: "18:00", df_select.columns[20]: "19:00", df_select.columns[21]: "20:00",
                 df_select.columns[22]: "21:00", df_select.columns[23]: "22:00", df_select.columns[24]: "23:00",
                 df_select.columns[0]: "date"}, inplace=True)

    df_long = pd.melt(df_select,
                      id_vars=df_select.columns[0],  # Column 0: 'date' remains as identifier
                      value_vars=df_select.iloc[:, 1:].columns,  # Columns 1 thru 24 
                      var_name='time',
                      value_name='kw_usage')

    # Creating new column 'datetime'
    df_long['datetime'] = df_long['date'].astype(str) + ' ' + df_long['time'].astype(str)
    df_long['datetime'] = pd.to_datetime(df_long['datetime'], format='mixed')
    df_long = df_long.sort_values(by=['datetime'])

    df_long2 = df_long.iloc[:, [3, 2]]
    df_long2 = df_long2.drop_duplicates()
    df_filtered = df_long2.loc[df_long2['datetime'] >= util_date]
    df_filtered.to_csv(rf"{folder_path}\{file_name}-Transformed.csv", index=False)

# Create previously defined folder within every folder
# Copy previously defined file into every folder
def create_val_copy(directory):
    val_folder = val_folder_date

    file_1 = val_file
    # file2 = 

    for folder_name in os.listdir(directory):
        folder_path = os.path.join(directory, folder_name)

        if os.path.isdir(folder_path):
            shutil.copy(file_1, folder_path)
            # shutil.copy(file_2, folder_path)
            os.makedirs(fr"{folder_path}\{val_folder}", exist_ok=True)

    print("Files copied to all sub-folders, Folders created")

# Move all CSV files and transformed CSV files into the appropriate folders
def move_files(directory):
    subfolders = [f for f in os.listdir(directory) if os.path.isdir(os.path.join(directory, f))]

    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)

        try:
            if os.path.isfile(file_path):
                for folder in subfolders:
                    if folder in file_name:
                        target_folder = os.path.join(directory, folder)
                        shutil.move(file_path, target_folder)
                        # print(f'moved {file_name} to {target_folder}')
        except shutil.Error:
            print('folder exists')

    print('All files moved to their folders')


create_folder(folder_path)

for i in range(len(xlsx_files)):
    df = load_xlsx(xlsx_files[i])
    transform(df, os.path.basename(xlsx_files[i]))
    files_remain -= 1
    print(f'{files_remain} file transformations remain')

create_val_copy(folder_path)
move_files(folder_path)