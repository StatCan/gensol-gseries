# G-Series

## Description

G‑Series is Statistics Canada’s (StatCan) generalized system devoted to
the benchmarking and reconciliation of time series data. The methods
used in G‑Series essentially come from

- Dagum, E. B., and P. Cholette (2006). *Benchmarking, Temporal
  Distribution and Reconciliation Methods of Time Series*.
  Springer-Verlag, New York, Lecture Notes in Statistics, Vol. 186.
  [doi:10.1007/0-387-35439-5](https://doi.org/10.1007/0-387-35439-5)

### Time Series Benchmarking

Goal: restore coherence between time series data of the same target
variable measured at different frequencies (e.g., sub-annually and
annually).

The family of topics included under the *benchmarking umbrella* in
G‑Series includes, among others, *temporal distribution* (the reciprocal
action of benchmarking: disaggregation of the benchmark series into more
frequent observations), *calendarization* (a special case of temporal
distribution) and *linking* (the connection of different time series
segments into a single consistent time series).

### Time Series Reconciliation

Goal: restore cross-sectional (contemporaneous) constraints in a system
of time series measured at the same frequency (e.g., provincial and
national series) with the optional preservation of temporal constraints.

The reconciliation of aggregation tables (data cubes) involving only
additivity constraints is called *raking* in G‑Series while *balancing*
refers to a more general class of reconciliation problems involving any
type of linear constraints (including inequality constraints).

## Software Availability

While early versions of G‑Series (v1.04 and v2.0) were developed in
SAS^(®), the software became an open-source tool with the release of
G‑Series 3.0 (R package gseries 3.0.0). This project is devoted to the
open-source version of G‑Series (R package gseries). Email us at
<g-series@statcan.gc.ca> for information about the SAS^(®) versions.
StatCan employees can also visit the G‑Series Confluence page on the
agency’s intranet (search for “G-Series \| G-Séries” in Confluence).

## Training

StatCan offers training on these topics. Visit the following pages on
the agency’s website for more information:

- [Theory and Application of Benchmarking (Course code
  0436)](https://www.statcan.gc.ca/en/training/statistical/0436)
- [Theory and Application of Reconciliation (Course code
  0437)](https://www.statcan.gc.ca/en/training/statistical/0437)

## Contact - Support

G‑Series support is provided by the Time Series Research and Analysis
Centre (TSRAC) in the Economic Statistics Methods Division (ESMD) and
the Digital Processing Solutions Division (DPSD). Email us at
<g-series@statcan.gc.ca> for information or help using G‑Series. GitHub
account holders can also request information, ask questions or report
problems through the G‑Series GitHub project
[Issues](https://github.com/StatCan/gensol-gseries/issues) page. StatCan
employees can do the same through the **Issues** page of the G‑Series
GitLab development project hosted on the agency’s intranet (search for
“G-Series in R - G-Séries en R” in GitLab).
