using System.Text.RegularExpressions;

namespace Foxtopia.Launcher;

/// <summary>
/// Orders release tags only when both are recognizable semantic versions.
/// Unknown tags are deliberately unordered: a guess could replace a newer
/// installed game with an older release.
/// </summary>
internal static class ReleaseVersion
{
    private static readonly Regex Pattern = new(
        @"^[vV]?(?<major>0|[1-9][0-9]*)\.(?<minor>0|[1-9][0-9]*)\.(?<patch>0|[1-9][0-9]*)(?:-(?<pre>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$",
        RegexOptions.CultureInvariant);

    public static int? Compare(string candidate, string installed)
    {
        var left = Parse(candidate);
        var right = Parse(installed);
        if (left is null || right is null) return null;

        for (var i = 0; i < left.Core.Length; i++)
        {
            var order = CompareNumeric(left.Core[i], right.Core[i]);
            if (order != 0) return order;
        }

        if (left.PreRelease.Length == 0) return right.PreRelease.Length == 0 ? 0 : 1;
        if (right.PreRelease.Length == 0) return -1;

        for (var i = 0; i < Math.Min(left.PreRelease.Length, right.PreRelease.Length); i++)
        {
            var leftIdentifier = left.PreRelease[i];
            var rightIdentifier = right.PreRelease[i];
            var leftNumeric = IsNumeric(leftIdentifier);
            var rightNumeric = IsNumeric(rightIdentifier);
            if (leftNumeric != rightNumeric) return leftNumeric ? -1 : 1;
            var order = leftNumeric
                ? CompareNumeric(leftIdentifier, rightIdentifier)
                : StringComparer.Ordinal.Compare(leftIdentifier, rightIdentifier);
            if (order != 0) return order;
        }
        return left.PreRelease.Length.CompareTo(right.PreRelease.Length);
    }

    private static Parts? Parse(string value)
    {
        if (value.Length is 0 or > 70) return null;
        var match = Pattern.Match(value);
        if (!match.Success) return null;
        var preRelease = match.Groups["pre"].Success
            ? match.Groups["pre"].Value.Split('.')
            : [];
        if (preRelease.Any(part => IsNumeric(part) && part.Length > 1 && part[0] == '0'))
            return null;
        return new Parts(
            [match.Groups["major"].Value, match.Groups["minor"].Value, match.Groups["patch"].Value],
            preRelease);
    }

    private static bool IsNumeric(string value) => value.All(c => c is >= '0' and <= '9');

    private static int CompareNumeric(string left, string right)
    {
        var lengthOrder = left.Length.CompareTo(right.Length);
        return lengthOrder != 0 ? lengthOrder : StringComparer.Ordinal.Compare(left, right);
    }

    private sealed record Parts(string[] Core, string[] PreRelease);
}
