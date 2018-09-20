namespace Hsbot.Slack.Core.Random
{
  public class RandomNumberGenerator : IRandomNumberGenerator
  {
    private readonly System.Random _rng;

    public RandomNumberGenerator()
    {
      _rng = new System.Random();
    }

    public RandomNumberGenerator(int seed)
    {
      _rng = new System.Random(seed);
    }

    
    /// <inheritdoc />
    public double Generate()
    {
      return _rng.NextDouble();
    }
  }
}