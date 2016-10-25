//
//  CXMLNode_PrivateExtensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 03/07/08.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CXMLNode_PrivateExtensions.h"

#import "CXMLElement.h"
#import "CXMLDocument_PrivateExtensions.h"
#import "CXMLUnsupportedNode.h"


@implementation CXMLNode (CXMLNode_PrivateExtensions)

- (id)initWithLibXMLNode:(xmlNodePtr)inLibXMLNode freeOnDealloc:(BOOL)infreeOnDealloc
{
if (inLibXMLNode == NULL)
	return nil;

if ((self = [super init]) != NULL)
	{
	self.node = inLibXMLNode;
	self.freeNodeOnRelease = infreeOnDealloc;
	}
return(self);
}

+ (id)nodeWithLibXMLNode:(xmlNodePtr)inLibXMLNode freeOnDealloc:(BOOL)infreeOnDealloc
{
    // TODO more checking.
    if (inLibXMLNode == NULL)
        return nil;

    if (inLibXMLNode->_private)
        return((__bridge id)inLibXMLNode->_private);

        Class theClass = [self nodeClassForLibXMLNode:inLibXMLNode];

    CXMLNode *theNode = [[theClass alloc] initWithLibXMLNode:inLibXMLNode freeOnDealloc:infreeOnDealloc];


    if (inLibXMLNode->doc != NULL) {
        CXMLDocument *theXMLDocument = (__bridge CXMLDocument *)inLibXMLNode->doc->_private;
        if (theXMLDocument != NULL) {
            NSAssert([theXMLDocument isKindOfClass:[CXMLDocument class]] == YES, @"TODO");

            [[theXMLDocument nodePool] addObject:theNode];

            theNode.node->_private = (__bridge void *)theNode;
        }
    }
    return(theNode);
}

+ (Class)nodeClassForLibXMLNode:(xmlNodePtr)inLibXMLNode {
    Class theClass;
    
    switch (inLibXMLNode->type)
	{
        case XML_ELEMENT_NODE:
            theClass = [CXMLElement class];
            break;
        case XML_DOCUMENT_NODE:
            theClass = [CXMLDocument class];
            break;
        case XML_ATTRIBUTE_NODE:
        case XML_TEXT_NODE:
        case XML_CDATA_SECTION_NODE:
        case XML_COMMENT_NODE:
            theClass = [CXMLNode class];
            break;
        default:
            theClass = [CXMLUnsupportedNode class];
	}
    
    return theClass;
}

- (void)invalidate;
    {
    if (self.node)
        {
        if (self.freeNodeOnRelease)
            {
            xmlUnlinkNode(self.node);
            xmlFreeNode(self.node);
            }

        self.node = NULL;
        }
    }

+ (xmlElementType)elementTypeForNodeKind:(CXMLNodeKind)nodeKind {
    
    switch (nodeKind) {
        case CXMLInvalidKind:
            return 0;
            
        case CXMLElementKind:
            return XML_ELEMENT_NODE;
            
        case CXMLAttributeKind:
            return XML_ATTRIBUTE_NODE;
            
        case CXMLTextKind:
            return XML_TEXT_NODE;
            
        case CXMLProcessingInstructionKind:
            return XML_PI_NODE;
            
        case CXMLCommentKind:
            return XML_COMMENT_NODE;
            
        case CXMLNotationDeclarationKind:
            return XML_NOTATION_NODE;
            
        case CXMLDTDKind:
            return XML_DTD_NODE;
            
        case CXMLElementDeclarationKind:
            return XML_ELEMENT_DECL;
            
        case CXMLAttributeDeclarationKind:
            return XML_ATTRIBUTE_DECL;
            
        case CXMLEntityDeclarationKind:
            return XML_ENTITY_DECL;
            
        case CXMLNamespaceKind:
            return XML_NAMESPACE_DECL;
            
        case CXMLEntityReferenceKind:
            return XML_ENTITY_REF_NODE;
            
        case CXMLCDataSectionNodeKind:
            return XML_CDATA_SECTION_NODE;
    }
}

- (xmlElementType)elementTypeForNodeKind:(CXMLNodeKind)nodeKind {
    return [CXMLNode elementTypeForNodeKind:nodeKind];
}

+ (CXMLNodeKind)nodeKindForElementType:(xmlElementType)elementType {

    switch (elementType) {
        case XML_ELEMENT_NODE:
            return CXMLElementKind;

        case XML_ATTRIBUTE_NODE:
            return CXMLAttributeKind;
            
        case XML_TEXT_NODE:
            return CXMLTextKind;
            
        case XML_PI_NODE:
            return CXMLProcessingInstructionKind;
            
        case XML_COMMENT_NODE:
            return CXMLCommentKind;
            
        case XML_NOTATION_NODE:
            return CXMLNotationDeclarationKind;
            
        case XML_DTD_NODE:
            return CXMLDTDKind;
            
        case XML_ELEMENT_DECL:
            return CXMLElementDeclarationKind;
            
        case XML_ATTRIBUTE_DECL:
            return CXMLAttributeDeclarationKind;
            
        case XML_ENTITY_DECL:
            return CXMLEntityDeclarationKind;
            
        case XML_NAMESPACE_DECL:
            return CXMLNamespaceKind;
            
        case XML_ENTITY_REF_NODE:
            return CXMLEntityReferenceKind;
            
        case XML_CDATA_SECTION_NODE:
            return CXMLCDataSectionNodeKind;
            
        default:
            return CXMLInvalidKind;
    }
}

- (CXMLNodeKind)nodeKindForElementType:(xmlElementType)elementType {
    return [CXMLNode nodeKindForElementType:elementType];
}

@end
