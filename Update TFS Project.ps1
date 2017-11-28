<#  Name: Update TFS Project to utilize new components such as code review
    Usage: To run this script you need to have Visual Studio. Once Visual Studio is installed, add the directory
        "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE" to your environment variable PATH.
        This will allow this script to use the witadmin.exe provided by Microsoft Visual Studio.
    Date Updated: 4/17/2017
#>

$project = 'DTCC' # Project Name
$collectionURL = 'https://tfs.aag.gfrinc.net/tfs/GAFRI-Collection' # Collection URL

#########################################################################################################################
$path = '\\cinfile01\GAFRI\Shared\GAFRI IT\Infrastructure_Operations\ITSM\ITSM Release Management\CMMI\WorkItem Tracking'

witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\FeedbackRequest.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\FeedbackResponse.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\CodeReviewRequest.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\CodeReviewResponse.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Bug.xml";
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\ChangeRequest.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Epic.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Feature.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Issue.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Requirement.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Risk.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\Task.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\TestPlan.xml"; 
witadmin importwitd /collection:$collectionURL /p:$project /f:"$path\TypeDefinitions\TestSuite.xml"; 
witadmin importcategories /collection:$collectionURL /p:$project /f:"$path\Categories.xml"; 
witadmin importprocessconfig /collection:$collectionURL /p:$project /f:"$path\Process\ProcessConfiguration.xml" 