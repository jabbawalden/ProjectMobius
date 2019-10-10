class UWidgetHealth : UUserWidget
{
    AMobiusGameMode GameMode;

    UFUNCTION(BlueprintEvent)
    UTextBlock GetHealthText()
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
    void UpdateHealthText(int points)
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