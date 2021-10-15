namespace TestProject
{
    using System;

    using Microsoft.VisualStudio.TestTools.UnitTesting;

    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void ThisTestWillPass() => Assert.IsTrue(true);

        [TestMethod]
        public void ThisTestWillFail() => Assert.Fail();

        [TestMethod]
        public void ThisTestWillRandomlyPassOrFail()
        {
            var r = new Random();
            var d = r.NextDouble(); // 0.0 <= x < 1.0
            Assert.IsTrue(d < 0.4); // 40% true
        }
    }
}
