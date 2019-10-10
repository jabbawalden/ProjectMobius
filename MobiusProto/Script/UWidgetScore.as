import AMobiusGameMode;

class UWidgetScore : UUserWidget
{
    AMobiusGameMode GameMode;

    UFUNCTION(BlueprintEvent)
    UTextBlock GetScoreText()
    {
        throw("You must override GetMainText from the widget blueprint to return the correct text widget.");
        return nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void Construct()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());
    }

    UFUNCTION()
    void UpdateScoreText(int points)
    {
        UTextBlock Score = GetScoreText();
        // Score.Text = FText::FromString("200" + GameMode.Points);   
        Score.Text = FText::FromString("" + points);     
    }

    UFUNCTION(BlueprintOverride)
    void Tick(FGeometry MyGeo ,float DeltaSeconds)
    {
        UpdateScoreText(GameMode.Points);
    }
}

UFUNCTION(Category = "Player HUD")
void AddWidgetToHUD(APlayerController PlayerController, TSubclassOf<UWidgetScore> WidgetClass)
{
    Print("Add to HUD called",5);
    UUserWidget UserWidget = WidgetBlueprint::CreateWidget(WidgetClass, PlayerController);
    UserWidget.AddToViewport();
}





