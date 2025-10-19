# Read Data
data <- read.csv("ControlVariates.csv")

# Correlation Coefficient
cor(data$X,data$Y)

# Calculate Beta
Beta <- -cov(data$X,data$Y)/var(data$Y)
Beta

# Control Variate Estimator
C <- mean(data$X + Beta*(data$Y - mean(data$Y)))
C

# CV Variance
Cvar <- (var(data$X)/100) - (cov(data$X,data$Y)^2 / (100*var(data$Y)))
Cvar

# CV Half-Width
qt(0.025,99,lower.tail=FALSE)*(Cvar/sqrt(100))

