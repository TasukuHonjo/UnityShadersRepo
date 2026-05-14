using TMPro;
using UnityEngine;
using UnityEngine.Playables;

public class TMPStringDisplay : PlayableBehaviour
{
    public TextMeshProUGUI textMeshProUGUI;
    public string displayText;

    [Header("Typewriter")]
    public float charInterval = 0.05f;
    public float punctuationWait = 0.2f;

    private bool initialized = false;
    private bool skipped = false;

    private float[] timings;
    public TMPStringDisplayController controller;

    public override void OnBehaviourPlay(Playable playable, FrameData info)
    {
        controller?.SetCurrentBehaviour(this);

        if (textMeshProUGUI == null) return;

        if (!initialized)
        {
            textMeshProUGUI.text = displayText;
            textMeshProUGUI.maxVisibleCharacters = 0;

            BuildTimings();

            skipped = false;
            initialized = true;
        }
    }

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        if (textMeshProUGUI == null) return;

        if (skipped)
        {
            textMeshProUGUI.maxVisibleCharacters = displayText.Length;
            return;
        }

        float currentTime = (float)playable.GetTime();

        int visible = 0;

        for (int i = 0; i < timings.Length; i++)
        {
            if (currentTime >= timings[i])
                visible++;
            else
                break;
        }

        textMeshProUGUI.maxVisibleCharacters = visible;
    }

    public override void OnBehaviourPause(Playable playable, FrameData info)
    {
        initialized = false;
    }

    public void Skip()
    {
        skipped = true;
    }

    void BuildTimings()
    {
        timings = new float[displayText.Length];

        float time = 0f;

        for (int i = 0; i < displayText.Length; i++)
        {
            char c = displayText[i];

            time += charInterval;

            if (IsPunctuation(c))
                time += punctuationWait;

            timings[i] = time;
        }
    }

    bool IsPunctuation(char c)
    {
        return c == 'A'
            || c == 'B'
            || c == ','
            || c == '.'
            || c == '!'
            || c == '?'
            || c == 'H';
    }

}