Add localisations to Xcode project

Minimum iOS 11

Enable base localization in the Xcode project. 
This will set Storyboards and Xibs as the base and will add additional string files for each extra language. 

Add the required extra languages in the Xcode project.

You should also add a pseudo language that will only be used to load marked texts into your project and enables Rigi to capture screenshots and recognise and extract the marked texts. 

Here we chose Zulu (South Africa) as a pseudo language. 

Add a new scheme to run pseudo language in simulator

In Xcode create (or copy) a new scheme and set App language to the new pseudo locale. When the locale can not be selected from the dropdown add a new launch argument -AppleLanguages


Then remove the pseudo locale from all distribution targets.
Alternatively we could create a specific target that will only be used for Rigi previewting and string extraction. Then we can add the pseudo language files as the only locale for this target. 

TODO - Test the proposed solution above


Add the Rigi SDK to the project

For now just copy the RigiSdk folder to the project and add the folder in Xcode.


Then activate the Rigi SDK in the appDelegate. You can also add a custom pre processor flag to enable Rigi Capture only for a specific build Target.

func applicationDidFinishLaunching(application: UIApplication, … ?) {
   #if RIGI_ENABLED
     let rigi = RigiCapture()
     rigi.settings.topViewControllers = ["SE_MenuViewController"]
     rigi.start()
   #endif
}
}

TODO 
	- Create precompiled framework
	- Create a Carthage / CocoaPods / Swift Package Manager package for Rigi 


Extract all localisation files from Xcode project

We use the tool BartyCrouch to extract localised texts from Storyboards and swift code and incrementally update all string files in the project.

https://github.com/Flinesoft/BartyCrouch

Installation:

 brew install bartycrouch 

Initialisation:

 bartycrouch init 

Update string files:

 bartycrouch update 


TODO - Add example .bartycrouch.toml settings file.



Zip all localisation files in Xcode project

Use the following command to find and zip all string files in the Xcode project.

 [PROJECT_FOLDER]/Rigi/bin/collect-strings.sh 


Upload the string files to the Rigi server

https://test.rigi.io/dashboard/projects

TODO - Now we need some ‘magic’ to process these files and create a Pseudo language


Download the pseudo string files from the Rigi server
Extract the dowloaded files in the project folder. Overwrite existing string files.

 [PROJECT_FOLDER]/Rigi/bin/update-strings.sh 



Make previews in the Simulator (manual)

Run the Target or Scheme that includes the preview code and the pseudo language.
Navigate through the app and record as much texts / screens as possible.



Upload the previews to the Rigi server

Zip the previews found in the Simulator folder

 [PROJECT_FOLDER]/Rigi/bin/collect-previews.sh 


Upload the previews to the Rigi server


Download localization files from the Rigi server

After making modifications to the translations or adding new texts to the pseudo language you can download the updated localisations files and extract them in the project folder.

 [PROJECT_FOLDER]/Rigi/bin/update-strings.sh 


Adding new texts to the project

Add new text to the code or storyboards

Extract the text with bartycrouch

 bartycrouch update 
Copy the new text in the source string file (EN)

Compact all string files

 [PROJECT_FOLDER]/Rigi/bin/collect-strings.sh 








Upload the generated file to the server


Approve the new strings for translation

Add the new texts by clicking update


Download the updated SE strings and ZU texts with the new Rigi codes


Extract the marked text files in the code project

 [PROJECT_FOLDER]/Rigi/bin/update-strings.sh 



Start the Rigi preview in the Simulator (manual)
Run the Target or Scheme that includes the preview code and the pseudo language. 
Make previews from the screens with the new (untranslated) texts.

Upload the new previews to the server


New strings files should manually be added to Rigi Goto files, find the new strings file in the source language (EN) and click Add?
To add the new text entries to Rigi, click Approve for translation 

Now the new texts can be translated and download from Rigi






Extract the translated text files in the code project

 [PROJECT_FOLDER]/Rigi/bin/update-strings.sh




Connecting to the Rigi server API

Add new API authentication user to Rigi







