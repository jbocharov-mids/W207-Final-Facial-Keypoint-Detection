library(doMC)
registerDoMC()

data.dir <- 'data/'
train.file <- paste0(data.dir, 'training.csv')
test.file <- paste0(data.dir, 'test.csv')

d.train <- read.csv(train.file, stringsAsFactors=F)
im.train <- foreach(im = d.train$Image, .combine=rbind) %dopar% { 
  as.integer(unlist(strsplit(im, " ")))
}
d.train$Image <- NULL

d.test  <- read.csv(test.file, stringsAsFactors=F)
im.test <- foreach(im = d.test$Image, .combine=rbind) %dopar% {
  as.integer(unlist(strsplit(im, " ")))
}
d.test$Image <- NULL

save(d.train, im.train, d.test, im.test, file='data.Rd')

p           <- matrix(data=colMeans(d.train, na.rm=T), nrow=nrow(d.test), ncol=ncol(d.train), byrow=T)
colnames(p) <- names(d.train)
predictions <- data.frame(ImageId = 1:nrow(d.test), p)

submission <- melt(predictions, id.vars="ImageId", variable.name="FeatureName", value.name="Location")

example.submission <- read.csv(paste0(data.dir, 'submissionFileFormat.csv'))
sub.col.names      <- names(example.submission)
example.submission$Location <- NULL
submission <- merge(example.submission, submission, all.x=T, sort=F)
submission <- submission[, sub.col.names]
write.csv(submission, file='results/submission_means.csv', quote=F, row.names=F)