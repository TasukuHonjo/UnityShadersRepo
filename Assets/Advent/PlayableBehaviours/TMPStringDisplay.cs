using TMPro;
using UnityEngine;
using UnityEngine.Playables;

public class TMPStringDisplay : PlayableBehaviour
{
    public TextMeshProUGUI textMeshProUGUI;
    public string displayText;

    public override void OnBehaviourPlay(Playable playable, FrameData info)
    {
        if (textMeshProUGUI != null)
        {
            textMeshProUGUI.text = displayText;
        }
    }
}