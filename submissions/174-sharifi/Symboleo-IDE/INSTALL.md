# Installation Guide
Please follow the instructions below.

## Requirements
- Eclipse 2019-09R or later.
- Xtext v2.19.0 or later.


## Instructions

- Open an xtext project from **File | Project | Xtext Project**:
![alt text](https://github.com/Smart-Contract-Modelling-uOttawa/Symboleo-IDE/blob/master/images/xtext-wizard.png "how to create a new xtext project")
- Create an xtext project in eclipse with the following parameters:
![alt text](https://github.com/Smart-Contract-Modelling-uOttawa/Symboleo-IDE/blob/master/images/xtext-setup.png "Symboleo xtext project parameters")

Make sure that the extension file is `.symboleo`.
- Replace all the contents (**_except the first two lines!_**) of `symboleo/src/symboleo/Symboleo.xtext` with the all the contents (**_again, except the first two lines!_**) of `org.xtext.csmLab.symboleo/src/org/xtext/csmLab/symboleo/Symboleo.xtext`.
- Right-click on `symboleo/src/symboleo/Symboleo.xtext`**| Run As |** `Generate Xtext Artifacts`.
- While running the workflow, you will see some warnings (in red), please ignore them. The final command that illustrates successful build is: `[main] INFO  .emf.mwe2.runtime.workflow.Workflow  - Done.`
- To experience Symboleo IDE in action, right-click on `symboleo` (the new project that was created) and navigate to **Run As |** `Eclipse Application`.
- You may see Errors in Workspace prompt, please ignore it and proceed with the launch.
- A runtime eclipse workspace will be opened. Create a New **General** Project (**File | New | Project… | General | Project**).
- Inside the project, create a new file with the `.symboleo` extension.
- System will prompt you to convert the project as a Xtext project, you should accept that for the Symboleo editor to work.
- Paste the text of the sample Sales-of-Goods contract (`Symboleo-IDE/samples/sogContract.txt`) in your `.symboleo` file. You should see keywords bolded.
![alt text](https://github.com/Smart-Contract-Modelling-uOttawa/Symboleo-IDE/blob/master/samples/sogOutput.png "Sales-of-Goods contract specified in Symboleo text editor")
- Now you can specify contracts in Symboleo and enjoy its syntax highlighting and autofill capabilities! (Note: by default in Eclipse, you need to enter `Ctrl` + `Space` to use autofill).
