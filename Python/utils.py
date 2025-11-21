import pandas as pd
from pathlib import Path

# Base folder for all data files
DATA_PATH = Path(r"D:\_Analysis\Projects\Global Indicators\Data")

def load_wb_csv(filename: str) -> pd.DataFrame:
    """
    Load a World Bank style CSV with 4 header rows.
    Automatically drops common unwanted columns and Unnamed columns.
    """
    df = pd.read_csv(DATA_PATH / filename, skiprows=4)

    # Drop common unnecessary columns if they exist
    cols_to_drop = ["Indicator Code", "Indicator Name", "Country Name"]
    df = df.drop(columns=[c for c in cols_to_drop if c in df.columns], errors="ignore")

    # Drop unnamed columns (like Unnamed: 69)
    df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

    return df

def filter_countries(df: pd.DataFrame, alpha3_list) -> pd.DataFrame:
    """
    Keep only rows where 'Country Code' is in the alpha3_list
    """
    return df[df["Country Code"].isin(alpha3_list)]

def reshape_long(df: pd.DataFrame, value_name: str) -> pd.DataFrame:
    """
    Convert a World Bank wide-format dataset to long format.
    Renames 'Country Code' to 'country_code'.
    """
    df = df.rename(columns={"Country Code": "country_code"})
    df_long = df.melt(
        id_vars=["country_code"],
        var_name="year",
        value_name=value_name
    )
    return df_long
