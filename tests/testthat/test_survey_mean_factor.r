context("Quick tests for added survey_mean / survey_total of grouping variables")

library(srvyr)
library(survey)

data(api)
dstrata <- apistrat %>%
  design_survey(strata = stype, weights = pw)

# One group
out_survey <- svymean(~awards, dstrata)

out_srvyr <- dstrata %>%
  group_by(awards) %>%
  summarize(pct = survey_mean())

test_that("survey_mean gets correct values for factors with single grouped surveys",
          expect_equal(c(out_survey[[1]], sqrt(diag(attr(out_survey, "var")))[[1]]),
                       c(out_srvyr[[1, 2]], out_srvyr[[1, 3]])))

test_that("survey_mean preserves factor levels",
          expect_equal(levels(apistrat$awards), levels(out_srvyr$awards)))


out_srvyr <- dstrata %>%
  group_by(awards = as.character(awards)) %>%
  summarize(pct = survey_mean())


test_that("survey_mean preserves factor levels",
          expect_equal("character", class(out_srvyr$awards)))

# 2+ groups
out_srvyr <- dstrata %>%
  group_by(stype, awards) %>%
  summarize(pct = survey_mean())

out_survey <- svyby(~awards, ~stype, dstrata, svymean)

test_that("survey_mean gets correct values when doing proportions with multiple groups",
          expect_equal(out_survey$awardsNo, out_srvyr %>% filter(awards == "No") %>% .$pct))

test_that("survey_mean gets correct values when doing proportions with multiple groups (se)",
          expect_equal(out_survey$`se.awardsNo`, out_srvyr %>% filter(awards == "No") %>% .$pct_se))
