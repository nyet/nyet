using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.WebTesting;
using System.Globalization;
using System.Text;
using System.ComponentModel;

namespace VSTSPrototype
{
    [DescriptionAttribute("Extracts the Checkbox status")]
    [DisplayNameAttribute("Custom Extract Checkbox")]
    public class CustomExtractionCheckbox : ExtractionRule
    {
        [DescriptionAttribute("Enter the value of the element's name attribute")]
        private string NameValue;
        public string Name
        {
            get { return NameValue; }
            set { NameValue = value; }
        }

        // The Extract method.  The parameter e contains the web performance test context.
        //---------------------------------------------------------------------
        public override void Extract(object sender, ExtractionEventArgs e)
        {
            if (e.Response.HtmlDocument != null)
            {
                foreach (HtmlTag tag in e.Response.HtmlDocument.GetFilteredHtmlTags(new string[] { "input" }))
                {
                    if (String.Equals(tag.GetAttributeValueAsString("name"), Name, StringComparison.InvariantCultureIgnoreCase))
                    {
                        string formFieldValue = tag.GetAttributeValueAsString("checked");
                        if (formFieldValue == null)
                        {
                            formFieldValue = "off";
                        }
                        else
                        {
                            if (formFieldValue.ToLower().Equals("checked"))
                            {
                                formFieldValue = "on";
                            }
                            else
                            {
                                formFieldValue = "off";
                            }
                        }
                        // add the extracted value to the web performance test context
                        e.WebTest.Context.Add(this.ContextParameterName, formFieldValue);
                        e.Success = true;
                        return;
                    }
                }
            }
            // If the extraction fails, set the error text that the user sees
            e.Success = false;
            e.Message = String.Format(CultureInfo.CurrentCulture, "Not Found: {0}", Name);
        }
    }
}
