/* optimization of recommended contract */
***************************************************************************

* create dataset, variables are:
1. week number
2. storage tank inflow(from rain precipitation)
3. unit treatment cost for precipitation
4. min gallons in the water tank each week
5. percent of water used from tank water (EECSI membership requirement: 25%)
6. forecast demand for the next four week (enter the predicted demand that we got from the first question)
;
data WEEKS;
input weekNo tankIn treatmentfee tankMin eliteRatio forecastDemand;
datalines;
1 12000 0.18 30000 0.25 56344.64
2 18000 0.18 30000 0.25 56209.59
3 20000 0.10 30000 0.25 56918.96
4 22000 0.10 30000 0.25 57401.27
;



proc optmodel;
*declare index sets, <num> is for numeric;
set <num> WEEKS;



*declare parameters;
num TankIn{WEEKS};
num TreatmentFee{WEEKS};
num TankMin{WEEKS};
num EliteRatio{WEEKS};
num ForecastDemand{WEEKS};



/* read in data; */
read data WEEKS into WEEKS = [weekNo] tankIn treatmentFee tankMin eliteRatio forecastDemand;



*print index set in the log and check if it's correctly decalred;
put WEEKS=;



/* declare variables: */
*Tank_Water_Usage:Tank water usage (water used from the tank), unit:gallon;
var Tank_Water_Usage{WEEKS}>=0;
*Purchased_Water:purchased water usage(water purchased from the Water Co.), unit:gallon;
var Purchased_Water{WEEKS}>=0;



/* create implicit variables; */
* TankStorage: gallons of water in the water tank;
impvar TankStorage{i in WEEKS} = if i=1 then 62500 + TankIn[i] - Tank_Water_Usage[i]
else TankStorage[i-1] + TankIn[i] - Tank_Water_Usage[i];

*TankCost: tank water cost (tank inflow * the treatment cost per gallon),inflow/rain precipitation needed to be treated before stored to the tank;
impvar TankCost{i in WEEKS} = TankIn[i] * TreatmentFee[i];



*PurchaseCost1: purchasing cost of water in next 4 weeks if choose contract 1;
impvar PurchaseCost1{i in WEEKS} = if Purchased_Water[i] >= 25000 then 0.15 * Purchased_Water[i]
else if Purchased_Water[i] > 0 then 0.15 * 25000
else 0;
*PurchaseCost2: purchasing cost of water in next 4 weeks if choose contract 2;
impvar PurchaseCost2{i in WEEKS} = if Purchased_Water[i] >= 35000 then 0.12 * Purchased_Water[i]
else if Purchased_Water[i] > 0 then 0.12 * 35000
else 0;
*PurchasingCost: choose the contract with a lower total costs as the PurchasingCost over the next 4 weeks;
impvar PurchaseCost{i in WEEKS} = if (sum{i in WEEKS} PurchaseCost1[i] - sum{i in WEEKS} PurchaseCost2[i]) > 0 then PurchaseCost2[i]
else PurchaseCost1[i];

* unit cost of the chosen contract ;
impvar Unit_Cost{i in WEEKS} = if (sum{i in WEEKS} PurchaseCost1[i] - sum{i in WEEKS} PurchaseCost2[i]) > 0 then 0.12
else 0.15;



*total water costs over the next four weeks;
min TotalCost = sum{i in WEEKS} (TankCost[i] + PurchaseCost[i]);



/* declare constraints */
* constraint 1: Water Storage Tank must NOT drop below 30,000 gallons during any week;
con Limit{i in WEEKS}: TankStorage[i] >= TankMin[i];
*constraint 2: as a member of EESCI, at least 25% of all water supplied to Building T each week must come from the Water Storage Tank;
con usageRate{i in WEEKS}: Tank_Water_Usage[i] / (Tank_Water_Usage[i] + Purchased_Water[i]) >= EliteRatio[i];
*constraint 3: sum of water used from tank and water used from procurement must >= to forecasted water demand for each week;
con TotalGallon{i in WEEKS}: (Tank_Water_Usage[i] + Purchased_Water[i]) >= ForecastDemand[i];




/* solve the problem */
solve;



/* print report */
print Tank_Water_Usage Purchased_Water Unit_Cost;
print TankStorage;
print 'XYZ Corporation total water cost over the next 4 weeks:' (TotalCost) dollar.;



/* optimization of alternative contract */
**********************************************************************************;

* create dataset, variables are:
1. week number
2. storage tank inflow(from rain precipitation)
3. unit treatment cost for precipitation
4. min gallons in the water tank each week
5. percent of water used from tank water (EECSI membership requirement: 25%)
6. forecast demand for the next four week (enter the predicted demand that we got from the first question)
;
data WEEKS;
input weekNo tankIn treatmentfee tankMin eliteRatio forecastDemand;
datalines;
1 12000 0.18 30000 0.25 56344.64
2 18000 0.18 30000 0.25 56209.59
3 20000 0.10 30000 0.25 56918.96
4 22000 0.10 30000 0.25 57401.27
;



proc optmodel;
*declare index sets, <num> is for numeric;
set <num> WEEKS;



*declare parameters;
num TankIn{WEEKS};
num TreatmentFee{WEEKS};
num TankMin{WEEKS};
num EliteRatio{WEEKS};
num ForecastDemand{WEEKS};



/* read in data; */
read data WEEKS into WEEKS = [weekNo] tankIn treatmentFee tankMin eliteRatio forecastDemand;



*print index set in the log and check if it's correctly decalred;
put WEEKS=;



/* declare variables: */
*Tank_Water:Tank water usage (water used from the tank), unit:gallon;
var Tank_Water{WEEKS}>=0;
*Purchased_Water:purchased water usage(water purchased from the Water Co.), unit:gallon;
var Purchased_Water{WEEKS}>=0;



/* create implicit variables; */
* TankStorage: gallons of water in the water tank;
impvar TankStorage{i in WEEKS} = if i=1 then 62500 + TankIn[i] - Tank_Water[i]
else TankStorage[i-1] + TankIn[i] - Tank_Water[i];

*TankCost: tank water cost (tank inflow * the treatment cost per gallon),inflow/rain precipitation needed to be treated before stored to the tank;
impvar TankCost{i in WEEKS} = TankIn[i] * TreatmentFee[i];



*PurchaseCost1: purchasing cost of water in next 4 weeks if choose contract 1;
impvar PurchaseCost1{i in WEEKS} = if Purchased_Water[i] >= 25000 then 0.15 * Purchased_Water[i]
else if Purchased_Water[i] > 0 then 0.15 * 25000
else 0;



*total water costs over the next four weeks;
min TotalCost = sum{i in WEEKS} (TankCost[i] + PurchaseCost1[i]);



/* declare constraints */
* constraint 1: Water Storage Tank must NOT drop below 30,000 gallons during any week;
con Limit{i in WEEKS}: TankStorage[i] >= TankMin[i];
*constraint 2: as a member of EESCI, at least 25% of all water supplied to Building T each week must come from the Water Storage Tank;
con usageRate{i in WEEKS}: Tank_Water[i] / (Tank_Water[i] + Purchased_Water[i]) >= EliteRatio[i];
*constraint 3: sum of water used from tank and water used from procurement must >= to forecasted water demand for each week;
con TotalGallon{i in WEEKS}: (Tank_Water[i] + Purchased_Water[i]) >= ForecastDemand[i];




/* solve the problem */
solve;



/* print report */
print Tank_Water Purchased_Water;
print TankStorage;
print 'XYZ Corporation total water cost over the next 4 weeks（alternative contract）:' (TotalCost) dollar.;