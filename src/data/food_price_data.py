```python
import pandas as pd
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import seaborn as sns

# Step 1: Identify and source data sources for food price inflation
data_url = 'https://raw.githubusercontent.com/mlundquist/FoodPriceInflation/master/data/food_prices.csv'
df_food_prices = pd.read_csv(data_url)

# Step 2: Set up data storage and preprocessing pipelines
def preprocess_data(df):
    df['Date'] = pd.to_datetime(df['Date'])
    df.set_index('Date', inplace=True)
    return df

df_food_prices_preprocessed = preprocess_data(df_food_prices)

# Step 3: Create initial visualizations of the collected data
def plot_food_price_inflation(df, country='World'):
    sns.lineplot(data=df[df['Country'] == country])
    plt.title(f'Food Price Inflation in {country}')
    plt.xlabel('Year')
    plt.ylabel('Price Index')
    plt.show()

plot_food_price_inflation(df_food_prices_preprocessed)
```