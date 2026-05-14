using TMPro;
using UnityEngine;
using UnityEngine.Playables;

public class TMPTypewriterBehaviour : PlayableBehaviour
{
    public TextMeshProUGUI textMeshProUGUI;
    public string displayText;

    private bool initialized = false;

    public override void OnBehaviourPlay(Playable playable, FrameData info)
    {
        if (textMeshProUGUI == null) return;

        // クリップ開始時に一度だけ実行
        if (!initialized)
        {
            textMeshProUGUI.text = displayText;
            textMeshProUGUI.maxVisibleCharacters = 0;
            initialized = true;
        }
    }

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        if (textMeshProUGUI == null) return;

        double duration = playable.GetDuration();
        double currentTime = playable.GetTime();

        float progress = (float)(currentTime / duration);

        int totalChars = displayText.Length;
        int visibleChars = Mathf.FloorToInt(totalChars * progress);

        textMeshProUGUI.maxVisibleCharacters = visibleChars;
    }

    public override void OnBehaviourPause(Playable playable, FrameData info)
    {
        initialized = false;
    }
}