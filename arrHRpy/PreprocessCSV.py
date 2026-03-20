import pandas as pd
import numpy as np

test_path = "arrHRpy\\csv\\ReoBreath.avt.csv"

WINDOWS = [6, 12, 18, 30, 60, 90]

def get_data(csv_path: str) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df = df[df['hr'] > 0]
    return df

def get_windows_df(data_df: pd.DataFrame, win_i: int = 0) -> pd.DataFrame:
    win = WINDOWS[win_i]
    mask_arr = pd.Series(False, index=data_df.index)
    mask_empty = pd.Series(False, index=data_df.index)

    for index, row in data_df.iterrows():
        # новое окно минимум через два окна от предыдущего, причем ближайшая аритмия слева: 2 окна - 1
        if index >= 3 * win - 1 and row["arr"] and not data_df.iloc[index - 3 * win + 1:index]["arr"].any():
            mask_arr.iloc[index - win:index] = True

        # в окне и его окрестности в два окна не должно быть аритмий, причем окрестности не должны пересекаться
        if (index in range(4 * win + 1, len(data_df) - 3 * win + 1) and
            (data_df.iloc[index - 3 * win + 1:index]["hr"] > 0).all() and
            not data_df.iloc[index - 2 * win:index + 3 * win]["arr"].any() and
            not mask_empty.iloc[index - 4 * win - 1:index].any()
            ):
            mask_empty.iloc[index:index + win] = True
        
    windows_df = pd.DataFrame({
        "arr_hr": data_df["hr"].where(mask_arr, 0),
        "empty_hr": data_df["hr"].where(mask_empty, 0),
        "arr_bool": data_df["arr"]
    })

    return windows_df

# data = get_data(test_path)
# df = get_windows_df(data)
# (df["arr_hr"] != 0).sum() / WINDOWS[0]
# print(df[80:120])
