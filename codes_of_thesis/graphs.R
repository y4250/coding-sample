###########################
#       Yunfeng Wu        #
#    yw4250@columbia.edu  #
#    Columbia University  #
#    Econ  Thesis Code    #
###########################


library(ggplot2)
##first-child
data <- data.frame(
  Year = c(2010, 2012, 2014, 2016, 2018, 2020),
  Estimate = c(.1735312,.1603866,.1232109,.126133,.1366215,.1220189),
  Lower_CI = c(.1045697,.1012282,.0397428, .0531483,.0674422,.0204921),
  Upper_CI = c(.2424926,.219545,.2066791,.1991177,.2058009,.2235458)
)

ggplot(data, aes(x = Year, y = Estimate)) +
  geom_point(color = "blue") +  
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
  labs(
    x = "Year", y = "Estimate") +
  scale_x_continuous(breaks = seq(2010, 2020, by = 2)) +  
  scale_y_continuous(limits = c(0, 0.4)) +  
  theme(
    axis.title.x = element_text(size = 8),  
    axis.title.y = element_text(size = 8),  
    axis.text.x = element_text(size = 10),    
    axis.text.y = element_text(size = 10)     
  )

##second-child
data <- data.frame(
  Year = c(2010, 2012, 2014, 2016, 2018, 2020),
  Estimate = c(.1221195,.1028458,.0792336, .1019507,.1017429,.0982737),
  Lower_CI = c(.0981984,.0808229,.0521711,.0771254,.0780783,.0699719),
  Upper_CI = c(.1460406,.1248688,.106296,.1267759,.1254075,.1265755)
)


ggplot(data, aes(x = Year, y = Estimate)) +
  geom_point(color = "blue") +  
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
  labs( 
    x = "Year", y = "Estimate") +
  scale_x_continuous(breaks = seq(2010, 2020, by = 2)) + 
  scale_y_continuous(limits = c(0,0.2)) +  
  theme(
    axis.title.x = element_text(size = 8),  
    axis.title.y = element_text(size = 8), 
    axis.text.x = element_text(size = 10),    
    axis.text.y = element_text(size = 10)     
  )

##third-child
data <- data.frame(
  Year = c(2010, 2012, 2014, 2016, 2018, 2020),
  Estimate = c( -.0072923, -.0282919,-.0117206,-.0027642, -.0158482, -.0217559),
  Lower_CI = c( -.029133,-.0508466,-.0364194,-.0253555, -.0413042,-.0491287),
  Upper_CI = c(.0145484,-.0057373,.0129782,.0198271,.0096079,.005617)
)


ggplot(data, aes(x = Year, y = Estimate)) +
  geom_point(color = "blue") +  
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
  labs(
    x = "Year", y = "Estimate") +
  scale_x_continuous(breaks = seq(2010, 2020, by = 2)) +  
  scale_y_continuous(limits = c(-0.075,0.075)) +  
  theme(
    axis.title.x = element_text(size = 8), 
    axis.title.y = element_text(size = 8), 
    axis.text.x = element_text(size = 10),    
    axis.text.y = element_text(size = 10)  
  )

## DID robust graph
data <- data.frame(
  Year = c(2014, 2016, 2018),
  Estimate = c(.0100513,.0384102,-.0110373),
  Lower_CI = c(   -.0040823,.0228732,-.0283652),
  Upper_CI = c( .0241849,.0539472,.0062907)
)


ggplot(data, aes(x = Year, y = Estimate)) +
  geom_point(color = "blue") +  
  geom_errorbar(aes(ymin = Lower_CI, ymax = Upper_CI), width = 0.2) +  
  labs(
    x = "Year", y = "Estimate") +
  scale_x_continuous(breaks = seq(2014,2018, by = 2)) +  
  scale_y_continuous(limits = c(-0.03, 0.06)) +  
  theme(
    axis.title.x = element_text(size = 8),  
    axis.title.y = element_text(size = 8), 
    axis.text.x = element_text(size = 10),    
    axis.text.y = element_text(size = 10) 
  )