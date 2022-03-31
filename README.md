# MXAM Static Analysis Github Action

This action runs a MXAM checkset on a model.


## Action inputs

| Name | Description | Default |
| ---- | ----------- | ------- |
| `mxam_dir` | Directory of the MXAM installation | |
| `artifact` | Name of the Artifact to test with MXAM | |
| `artifact_dir` | Directory where the Artifact for testing is located | |
| `checkset` | Relative path of the checkset which should be run for the Artifact | |
| `checkset_dir` | Base directory of checksets | |

## Action outputs

The MXAM script provides a report which is located in `_results/MXAM/Report.pdf`.


## Using the example action

```yaml
jobs:
  example:
    name: mxam
    runs-on: self-hosted
    steps:
      - uses: MBSD-SDK/Action-RunMXAM@v0
        with:
            mxam_dir: "C:\\Tools\\MXAM\\7_2_0"
            artifact: "MXAM_Test"
            artifact_dir: ".\\testdata\\MXAM"
            checkset: "projects\\ef8\\HCP1\\hcp1_chassis_fixpoint.mxmp"
            checkset_dir: "C:\\Users\\DevInf-2\\Documents\\projects\\matlab-test\\script\\MXAM_Checks_v7.3.0\\MXAM_Checks"
```
