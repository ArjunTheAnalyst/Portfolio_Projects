# Data Jobs Market Analysis Dashboard

## Project Overview
This Power BI dashboard provides comprehensive analysis of the data job market, tracking 479,000 job postings to identify key trends in skills demand and salary distributions across various data roles and locations.

<img width="757" height="424" alt="image" src="https://github.com/user-attachments/assets/636bb3ec-9fe4-42bc-9a97-ccdd5aad0fd8" />

## Dashboard Features
- **Job Market Overview**: 479,000 total jobs analyzed with 4.8 average skills required per job
- **Skills Analysis**: Identifies top in-demand skills including Pylinx, SQL, AWS, Azure, and Power BI
- **Salary Benchmarking**: Median yearly salary ($113,000) and hourly rate ($47.62) across data roles
- **Interactive Filtering**: Dynamic filtering by job title and country with "Clear all slicers" functionality
- **Role Comparison**: Compare salaries and requirements across 10 major data roles

## Technical Implementation

### Power BI Development
**Data Transformation & Cleaning:**
- Extensive data cleaning performed using Power Query
- Data normalization and validation processes implemented
- Structured data model with optimized relationships

**DAX Measures Created:**
- `Job Count` = 479,000 (total jobs analyzed)
- `Skills per Job` = 4.8 (average skills required)
- `Median Yearly Salary` = $113,000
- `Median Hourly Salary` = $47.62
- `Job Percent` calculations for skills distribution
- Custom aggregations for salary comparisons

**Parameters Implemented:**
- **Job Title Parameter**: Dynamic filtering across all job titles
- **Country Parameter**: Geographic filtering capability
- **Interactive Slicers**: "Select Job Title" and "Select Country" with "Clear all slicers" reset function

**Visualizations Developed:**
- Skills distribution bar chart showing job percentage for top skills
- Salary comparison horizontal bar chart for top paying roles
- Key metrics cards for Job Count, Skills per Job, and Salary figures
- Interactive filtering system with visual feedback

## Key Insights Discovered

**Top Paying Data Roles:**
1. Senior Data Scientist
2. Machine Learning Engineer
3. Senior Data Engineer
4. Software Engineer
5. Data Engineer

**Most Valuable Skills:**
- Programming: Pylinx, R
- Databases: SQL, Snowflake, Databinds
- Cloud Platforms: AWS, Azure
- BI Tools: Power BI

**Market Analysis:**
- Strong demand across all data roles with 479K total positions
- Average of 4.8 skills required per job indicating role diversification
- Senior technical roles command premium salaries ($113K median)

### Interactive Features:
- Use **"Select Job Title"** dropdown to filter by specific roles
- Use **"Select Country"** dropdown for geographic analysis
- Click **"Clear all slicers"** to reset the dashboard view
- Hover over charts for detailed tooltips and percentages
- Observe real-time updates across all visualizations when filtering

## Skills Demonstrated
- **Power BI Development**: Dashboard design and implementation
- **DAX Programming**: Custom measures and calculations
- **Power Query**: Data transformation and cleaning
- **Data Modeling**: Relationship design and optimization
- **Business Intelligence**: Data visualization and insights generation
- **Parameter Design**: Interactive filtering systems
- **Data Analysis**: Market trends and salary benchmarking

---

*This dashboard was built using Power BI Desktop with advanced DAX measures, custom parameters, and comprehensive data cleaning processes.*

**Download the interactive dashboard:** [Data_Jobs_Dashboard.pbix](https://drive.google.com/file/d/1N1EpYu5OtSsqk1xDQK_cgTeupp0I0Gi-/view?usp=drive_link)
