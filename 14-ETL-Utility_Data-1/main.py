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

# Store all CSV files
csv_files = sorted(glob.glob(os.path.join(f'{folder_path}', "*.csv")))
files_remain = len(csv_files)


# Create a folder for every CSV file being transformed
def create_folder(directory):
    for file_name in os.listdir(directory):
        file_path = os.path.join(directory, file_name)

        if os.path.isfile(file_path):
            folder_name = os.path.splitext(file_name)[0]
            new_folder_path = os.path.join(directory, folder_name)
            os.makedirs(new_folder_path, exist_ok=True)

    print('Folders created')

# Read CSV file, select columns
def load_csv(file_path):
    df = pd.read_csv(file_path, parse_dates=[1])
    df = df.iloc[:, [1, 0, 3, 4]]
    df = df.drop_duplicates()
    return df

# Transform and filter the data
def transform(df_orig, file_name):
    df_orig['Start Date Time'] = pd.to_datetime(df_orig['Start Date Time'])

    df_filter_1 = df_orig[df_orig['Usage Unit'] == 'KWH']
    df_filter_2 = df_filter_1.loc[df_filter_1['Start Date Time'] >= util_date]

    df_final = df_filter_2.iloc[:, :4]
    df_wide = df_final.pivot_table(index='Start Date Time', columns='Meter Number', values='Usage', aggfunc='mean')
    df_wide = df_wide.sort_values(by=['Start Date Time'])

    df_wide.to_csv(rf"{folder_path}\{file_name}-Transformed.csv", index=True)

# Create previously defined folder within every folder
# Copy previously defined file into every folder
def create_val_copy(directory):
    val_folder = val_folder_date

    file_1 = val_file
    # file_2 =

    for folder_name in os.listdir(directory):
        folder_path = os.path.join(directory, folder_name)

        if os.path.isdir(folder_path):
            shutil.copy(file_1, folder_path)
            # shutil.copy(file_2, folder_path)
            os.makedirs(rf"{folder_path}\{val_folder}", exist_ok=True)

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

for i in range(len(csv_files)):
    df = load_csv(csv_files[i])
    transform(df, os.path.basename(csv_files[i]))
    files_remain -= 1
    print(f'{files_remain} file transformations remain')

create_val_copy(folder_path)
move_files(folder_path)