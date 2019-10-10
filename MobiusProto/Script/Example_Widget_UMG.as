
/**
 * This in an example for a baseclass for an UMG widget.
 *  You can create a widget blueprint and set this class as the parent class.
 *  Then you can create certain functionality in script while designing the UI
 *  in the widget blueprint.
 */
class UExampleWidget : UUserWidget
{
    float TimePassed = 0.f;

    // This function is specified as a BlueprintEvent,
    // you can override this function from the widget blueprint
    // to return the appropriate widget so the script has access to it.
    UFUNCTION(BlueprintEvent)
    UTextBlock GetMainText()
    {
        throw("You must override GetMainText from the widget blueprint to return the correct text widget.");
        return nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void Construct()
    {
    }

    UFUNCTION(BlueprintOverride)
    void Tick(FGeometry MyGeometry, float DeltaTime)
    {
        TimePassed += DeltaTime;

        UTextBlock TextDisplay = GetMainText();
        TextDisplay.Text = FText::FromString("Time Passed: "+TimePassed);
    }
};

/**
 * This is a global function that can add a widget of a specific class to a player's HUD.
 *  This can be called for example from level blueprint to specify which widget blueprint to show.
 */
UFUNCTION(Category = "Examples | Player HUD Widget")
void Example_AddExampleWidgetToHUD(APlayerController OwningPlayer, TSubclassOf<UExampleWidget> WidgetClass)
{
    UUserWidget UserWidget = WidgetBlueprint::CreateWidget(WidgetClass, OwningPlayer);
    UserWidget.AddToViewport();
}