namespace TestProject2
{
    using Microsoft.VisualStudio.TestTools.UnitTesting;

    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod_Pass()
        {
            Assert.IsTrue(true);
        }


        [TestMethod]
        public void TestMethod_Fail()
        {
            Assert.IsTrue(false);
        }
    }
}